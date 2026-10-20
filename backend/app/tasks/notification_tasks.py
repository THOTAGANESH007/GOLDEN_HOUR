"""
Celery notification task.

Flow on QR scan:
  1. Backend enqueues notify_emergency_contacts
  2. Celery worker picks it up
  3. For each contact: SMS → WhatsApp (if enabled)
  4. FCM push to patient
  5. If SMS fails all retries: email fallback
  6. Update scan_event notification status flags
"""
import asyncio
import logging
import uuid
from datetime import datetime, timezone

from celery import shared_task

from app.tasks.celery_app import celery_app

logger = logging.getLogger(__name__)


@celery_app.task(
    bind=True,
    max_retries=3,
    default_retry_delay=5,  # 5s, then 15s, then 30s
    name="app.tasks.notification_tasks.notify_emergency_contacts",
)
def notify_emergency_contacts(
    self,
    scan_event_id: str,
    user_id: str,
    qr_uid: str,
    patient_name: str | None,
    fcm_token: str | None,
    contacts: list[dict],   # [{name, phone, whatsapp_enabled}]
    scan_time_iso: str,
    maps_url: str | None,
    location_area: str | None,
    responder_name: str | None,
) -> dict:
    """
    Dispatch all notification channels for a QR scan event.
    contacts format: [{"name": str, "phone": str, "whatsapp_enabled": bool}]
    """
    try:
        return asyncio.run(
            _async_notify(
                scan_event_id=scan_event_id,
                user_id=user_id,
                patient_name=patient_name or "Unknown Patient",
                fcm_token=fcm_token,
                contacts=contacts,
                scan_time=datetime.fromisoformat(scan_time_iso),
                maps_url=maps_url,
                location_area=location_area,
                responder_name=responder_name,
            )
        )
    except Exception as exc:
        logger.error("Notification task failed: %s — retrying", exc)
        retry_countdown = 5 * (2 ** self.request.retries)   # 5, 10, 20s
        raise self.retry(exc=exc, countdown=retry_countdown)


async def _async_notify(
    scan_event_id: str,
    user_id: str,
    patient_name: str,
    fcm_token: str | None,
    contacts: list[dict],
    scan_time: datetime,
    maps_url: str | None,
    location_area: str | None,
    responder_name: str | None,
) -> dict:
    from app.services.notification_service import (
        send_sms,
        send_whatsapp,
        send_fcm_push,
        send_emergency_contact_fcm,
        send_email_fallback,
    )
    from app.database import AsyncSessionLocal
    from app.models.scan_event import ScanEvent
    from app.models.user import User
    from sqlalchemy import select, update

    results = {
        "sms_sent": False,
        "whatsapp_sent": False,
        "fcm_sent": False,
        "email_sent": False,
        "contacts_notified": 0,
    }

    # ── Check if any emergency contacts have Golden Hour app installed ────
    contact_phones = [c["phone"] for c in contacts if c.get("phone")]
    contact_fcm_tokens: dict[str, str] = {}
    if contact_phones:
        try:
            async with AsyncSessionLocal() as db:
                rows = (
                    await db.execute(
                        select(User.phone, User.fcm_token).where(
                            User.phone.in_(contact_phones),
                            User.fcm_token.isnot(None),
                        )
                    )
                ).all()
                contact_fcm_tokens = {r[0]: r[1] for r in rows if r[1]}
        except Exception as exc:
            logger.warning("Could not query emergency contacts FCM tokens: %s", exc)

    # ── Notify each emergency contact ──────────────────────────────────────
    for contact in contacts:
        phone = contact["phone"]
        whatsapp_enabled = contact.get("whatsapp_enabled", False)

        # 1. High-Priority FCM Push Notification (Free & Instant)
        contact_fcm = contact_fcm_tokens.get(phone)
        if contact_fcm:
            fcm_contact_ok = await send_emergency_contact_fcm(
                fcm_token=contact_fcm,
                patient_name=patient_name,
                location_area=location_area,
                maps_url=maps_url,
                scan_time=scan_time,
                responder_name=responder_name,
            )
            if fcm_contact_ok:
                results["fcm_sent"] = True
                results["contacts_notified"] += 1

        # 2. SMS Alert
        sms_ok = await send_sms(
            phone=phone,
            patient_name=patient_name,
            scan_time=scan_time,
            maps_url=maps_url,
            responder_name=responder_name,
        )

        if sms_ok:
            results["sms_sent"] = True
            if not contact_fcm:
                results["contacts_notified"] += 1
        else:
            logger.warning("SMS failed for contact %s", phone)

        # 3. WhatsApp Alert
        if whatsapp_enabled:
            wa_ok = await send_whatsapp(
                phone=phone,
                patient_name=patient_name,
                scan_time=scan_time,
                maps_url=maps_url,
                responder_name=responder_name,
            )
            if wa_ok:
                results["whatsapp_sent"] = True

    # ── FCM push to patient device ──────────────────────────────────────────
    if fcm_token:
        fcm_ok = await send_fcm_push(
            fcm_token=fcm_token,
            location_area=location_area,
            scan_time=scan_time,
            maps_url=maps_url,
            responder_name=responder_name,
        )
        if fcm_ok:
            results["fcm_sent"] = True

    # ── Update scan_event record with delivery status ───────────────────────
    async with AsyncSessionLocal() as db:
        try:
            await db.execute(
                update(ScanEvent)
                .where(ScanEvent.id == uuid.UUID(scan_event_id))
                .values(
                    sms_sent=results["sms_sent"],
                    whatsapp_sent=results["whatsapp_sent"],
                    fcm_sent=results["fcm_sent"],
                    email_sent=results["email_sent"],
                )
            )
            await db.commit()
        except Exception as exc:
            logger.error("Failed to update scan_event %s: %s", scan_event_id, exc)
            await db.rollback()

    logger.info(
        "Notification dispatch complete for scan %s: %s",
        scan_event_id,
        results,
    )
    return results

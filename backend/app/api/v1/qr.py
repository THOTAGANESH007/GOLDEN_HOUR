"""
QR endpoints: generate, regenerate, and the critical public scan endpoint.
"""
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.middleware.rate_limiter import limiter
from app.models.user import User
from app.schemas.profile import PublicProfileResponse
from app.services import qr_service
from app.services.qr_service import get_or_create_profile

router = APIRouter(prefix="/qr", tags=["QR Code"])


# ── POST /qr/generate ─────────────────────────────────────────────────────────

@router.post("/generate", status_code=status.HTTP_201_CREATED)
async def generate_qr(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create or retrieve the patient's QR UID."""
    profile = await get_or_create_profile(db, current_user)
    return {"qr_uid": profile.qr_uid, "qr_url": _build_url(profile.qr_uid)}


# ── POST /qr/regenerate ───────────────────────────────────────────────────────

@router.post("/regenerate")
async def regenerate_qr(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Invalidate current UID and issue a new one. Old URL → 404."""
    profile = await get_or_create_profile(db, current_user)
    profile = await qr_service.regenerate_qr(db, profile)
    return {
        "qr_uid": profile.qr_uid,
        "qr_url": _build_url(profile.qr_uid),
        "message": "QR regenerated — old URL is now invalid",
    }


# ── GET /qr/public/{uid} ──────────────────────────────────────────────────────

@router.get("/public/{uid}")
@limiter.limit("20/hour")
async def public_scan(
    uid: str,
    request: Request,
    background_tasks: BackgroundTasks,
    responder_name: str | None = None,
    responder_hospital: str | None = None,
    latitude: float | None = None,
    longitude: float | None = None,
    db: AsyncSession = Depends(get_db),
):
    """
    **PUBLIC — no auth required.**
    Called by the React responder web app on page load.

    1. Returns the patient's safe medical data
    2. Logs the scan event
    3. Enqueues Celery notification task (with fallback to BackgroundTasks)
    """
    # 1. Look up profile
    profile = await qr_service.get_profile_by_uid(db, uid)
    if profile is None:
        # Check if UID exists but is deactivated
        from sqlalchemy import select
        from app.models.profile import Profile
        result = await db.execute(select(Profile).where(Profile.qr_uid == uid))
        exists = result.scalar_one_or_none()
        if exists:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="QR_DEACTIVATED",
            )
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="QR_NOT_FOUND")

    # 2. Check deduplication
    suppressed = await qr_service.is_duplicate_scan(db, uid)

    # 3. Log scan event
    user_agent = request.headers.get("user-agent")
    scan_event = await qr_service.log_scan_event(
        db=db,
        user_id=profile.user_id,
        qr_uid=uid,
        responder_name=responder_name,
        responder_hospital=responder_hospital,
        latitude=latitude,
        longitude=longitude,
        user_agent=user_agent,
        suppressed=suppressed,
    )

    # 4. Enqueue notification task (only if not suppressed)
    if not suppressed:
        from app.models.emergency_contact import EmergencyContact
        from sqlalchemy import select as sa_select

        result = await db.execute(
            sa_select(EmergencyContact)
            .where(
                EmergencyContact.user_id == profile.user_id,
                EmergencyContact.notify_on_scan == True,  # noqa: E712
            )
            .order_by(EmergencyContact.sort_order)
        )
        contacts = result.scalars().all()
        contact_data = [
            {
                "name": c.name,
                "phone": c.phone,
                "whatsapp_enabled": c.whatsapp_enabled,
            }
            for c in contacts
        ]

        from app.tasks.notification_tasks import notify_emergency_contacts, _async_notify
        from app.models.user import User as UserModel
        import logging

        logger = logging.getLogger(__name__)

        user_result = await db.execute(
            sa_select(UserModel).where(UserModel.id == profile.user_id)
        )
        user = user_result.scalar_one_or_none()
        patient_display_name = profile.full_name if profile.show_name else "A Patient"
        maps_url = scan_event.google_maps_url

        try:
            notify_emergency_contacts.delay(
                scan_event_id=str(scan_event.id),
                user_id=str(profile.user_id),
                qr_uid=uid,
                patient_name=patient_display_name,
                fcm_token=user.fcm_token if user else None,
                contacts=contact_data,
                scan_time_iso=scan_event.scanned_at.isoformat(),
                maps_url=maps_url,
                location_area=scan_event.location_area,
                responder_name=responder_name,
            )
            logger.info("Notification task enqueued to Celery for scan %s", scan_event.id)
        except Exception as queue_exc:
            logger.warning(
                "Celery broker dispatch failed: %s — falling back to FastAPI BackgroundTasks",
                queue_exc,
            )
            background_tasks.add_task(
                _async_notify,
                scan_event_id=str(scan_event.id),
                user_id=str(profile.user_id),
                patient_name=patient_display_name,
                fcm_token=user.fcm_token if user else None,
                contacts=contact_data,
                scan_time=scan_event.scanned_at,
                maps_url=maps_url,
                location_area=scan_event.location_area,
                responder_name=responder_name,
            )

    # 5. Build and return safe public data
    data = await qr_service.get_safe_public_data(db, profile, scan_event.id)
    return data


def _build_url(uid: str | None) -> str:
    from app.config import get_settings
    s = get_settings()
    return f"{s.app_base_url}/p/{uid}"

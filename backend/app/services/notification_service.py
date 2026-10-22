"""
Notification service — SMS (Fast2SMS), WhatsApp Cloud API, FCM, Email (Resend).
All channels are called from the Celery task, not directly from the API.
"""
import json
import logging
from datetime import datetime, timezone

import httpx

from app.config import get_settings

settings = get_settings()
logger = logging.getLogger(__name__)


def _ist_time(dt: datetime | None = None) -> str:
    """Format a UTC datetime as HH:MM IST string."""
    from datetime import timedelta
    ist_offset = timedelta(hours=5, minutes=30)
    base = dt or datetime.now(timezone.utc)
    ist = base + ist_offset
    return ist.strftime("%H:%M IST")


# ── SMS via Fast2SMS ───────────────────────────────────────────────────────────

async def send_sms(
    phone: str,     # E.164: +91XXXXXXXXXX → strip to 10 digits for Fast2SMS
    patient_name: str,
    scan_time: datetime,
    maps_url: str | None,
    responder_name: str | None,
) -> bool:
    """Returns True on success."""
    # Fast2SMS expects 10-digit Indian number
    number = phone.lstrip("+").lstrip("91")[-10:]
    time_str = _ist_time(scan_time)
    location = maps_url or "Location unavailable"
    responder = responder_name or "Unknown"

    message = (
        f"EMERGENCY ALERT: {patient_name}'s medical QR was scanned. "
        f"Time: {time_str} | {location} "
        f"Responder: {responder} "
        "Please call 108 immediately. - Golden Hour"
    )

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                "https://www.fast2sms.com/dev/bulkV2",
                headers={"authorization": settings.fast2sms_api_key},
                params={
                    "variables_values": message,
                    "route": "q",
                    "numbers": number,
                },
                timeout=10,
            )
        data = resp.json()
        if data.get("return"):
            logger.info("SMS sent to %s", phone)
            return True
        logger.warning("SMS failed for %s: %s", phone, data)
        return False
    except Exception as exc:
        logger.error("SMS exception for %s: %s", phone, exc)
        return False


async def send_custom_sms(phone: str, message: str) -> bool:
    """Send arbitrary SMS text via Fast2SMS (e.g. for fallback OTP)."""
    if not settings.fast2sms_api_key:
        return False
    number = phone.lstrip("+").lstrip("91")[-10:]
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                "https://www.fast2sms.com/dev/bulkV2",
                headers={"authorization": settings.fast2sms_api_key},
                params={
                    "variables_values": message,
                    "route": "q",
                    "numbers": number,
                },
                timeout=10,
            )
        data = resp.json()
        return bool(data.get("return"))
    except Exception as exc:
        logger.error("Custom SMS exception for %s: %s", phone, exc)
        return False


# ── WhatsApp via Official Meta Cloud API ──────────────────────────────────────

async def send_whatsapp(
    phone: str,
    patient_name: str,
    scan_time: datetime,
    maps_url: str | None,
    responder_name: str | None,
) -> bool:
    """Send emergency alert via official Meta WhatsApp Cloud API."""
    if not settings.whatsapp_access_token or not settings.whatsapp_phone_number_id:
        logger.warning(
            "Meta WhatsApp Cloud API credentials not configured; skipping WhatsApp notification"
        )
        return False

    time_str = _ist_time(scan_time)
    location = maps_url or "Location unavailable"
    responder = responder_name or "Unknown responder"
    clean_phone = phone.lstrip("+").strip()

    url = f"https://graph.facebook.com/v21.0/{settings.whatsapp_phone_number_id}/messages"
    headers = {
        "Authorization": f"Bearer {settings.whatsapp_access_token}",
        "Content-Type": "application/json",
    }

    if settings.whatsapp_template_name:
        # Pre-approved Utility Template
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": clean_phone,
            "type": "template",
            "template": {
                "name": settings.whatsapp_template_name,
                "language": {"code": "en"},
                "components": [
                    {
                        "type": "body",
                        "parameters": [
                            {"type": "text", "text": patient_name},
                            {"type": "text", "text": time_str},
                            {"type": "text", "text": location},
                            {"type": "text", "text": responder},
                        ],
                    }
                ],
            },
        }
    else:
        # Direct formatted text alert
        message_text = (
            f"🚨 *EMERGENCY ALERT — Golden Hour*\n\n"
            f"*{patient_name}*'s medical emergency QR was just scanned.\n"
            f"⏰ *Time:* {time_str}\n"
            f"📍 *Location:* {location}\n"
            f"👤 *First Responder:* {responder}\n\n"
            f"Please call 108 or reach out immediately."
        )
        payload = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": clean_phone,
            "type": "text",
            "text": {
                "preview_url": True,
                "body": message_text,
            },
        }

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(url, headers=headers, json=payload, timeout=15)
        if resp.status_code in (200, 201):
            data = resp.json()
            if "messages" in data:
                msg_id = data["messages"][0].get("id", "")
                logger.info("WhatsApp sent via Meta Cloud API to %s (id: %s)", phone, msg_id)
                return True
        logger.warning(
            "Meta WhatsApp Cloud API failed for %s (%s): %s",
            phone,
            resp.status_code,
            resp.text,
        )
        return False
    except Exception as exc:
        logger.error("Meta WhatsApp Cloud API exception for %s: %s", phone, exc)
        return False


async def send_custom_whatsapp(phone: str, message_text: str) -> bool:
    """Send arbitrary text message (e.g. login OTP) via Meta WhatsApp Cloud API."""
    if not settings.whatsapp_access_token or not settings.whatsapp_phone_number_id:
        return False

    clean_phone = phone.lstrip("+").strip()
    url = f"https://graph.facebook.com/v21.0/{settings.whatsapp_phone_number_id}/messages"
    headers = {
        "Authorization": f"Bearer {settings.whatsapp_access_token}",
        "Content-Type": "application/json",
    }
    payload = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": clean_phone,
        "type": "text",
        "text": {
            "preview_url": False,
            "body": message_text,
        },
    }

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(url, headers=headers, json=payload, timeout=12)
        if resp.status_code in (200, 201):
            data = resp.json()
            if "messages" in data:
                logger.info("Custom WhatsApp message sent to %s", phone)
                return True
        logger.warning(
            "Meta WhatsApp custom message failed for %s (%s): %s",
            phone,
            resp.status_code,
            resp.text,
        )
        return False
    except Exception as exc:
        logger.error("Custom WhatsApp exception for %s: %s", phone, exc)
        return False


# ── FCM Push (to patient & emergency contacts) ────────────────────────────────

def _ensure_firebase_initialized() -> bool:
    """Ensure Firebase Admin SDK is initialized."""
    import os
    import firebase_admin
    from firebase_admin import credentials

    if firebase_admin._apps:
        return True

    cred_source = settings.firebase_credentials_json
    if cred_source and cred_source.strip().startswith("{"):
        import json
        cred = credentials.Certificate(json.loads(cred_source))
        firebase_admin.initialize_app(cred)
        return True
    elif cred_source and os.path.exists(cred_source):
        cred = credentials.Certificate(cred_source)
        firebase_admin.initialize_app(cred)
        return True
    else:
        try:
            firebase_admin.initialize_app()
            return True
        except Exception as e:
            logger.error("Could not initialize Firebase Admin SDK: %s", e)
            return False


async def send_fcm_push(
    fcm_token: str,
    location_area: str | None,
    scan_time: datetime,
    maps_url: str | None = None,
    responder_name: str | None = None,
) -> bool:
    """Send FCM push notification to the patient's device."""
    time_str = _ist_time(scan_time)
    area = location_area or "Unknown area"

    try:
        from firebase_admin import messaging

        if not _ensure_firebase_initialized():
            return False

        message = messaging.Message(
            notification=messaging.Notification(
                title="⚠️ Your Medical QR Was Scanned",
                body=f"Scanned near {area} at {time_str}. Tap to view details.",
            ),
            data={
                "type": "patient_qr_scan",
                "location_area": area,
                "scan_time": time_str,
                "maps_url": maps_url or "",
                "responder_name": responder_name or "Unknown",
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
            token=fcm_token,
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id="emergency_alerts",
                    priority="max",
                    default_sound=True,
                    default_vibrate_timings=True,
                    icon="ic_launcher",
                    color="#E53935",
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default", content_available=True)
                )
            ),
        )
        messaging.send(message)
        logger.info("FCM sent to patient device (token: %s…)", fcm_token[:12])
        return True
    except Exception as exc:
        logger.error("FCM exception for patient device: %s", exc)
        return False


async def send_emergency_contact_fcm(
    fcm_token: str,
    patient_name: str,
    location_area: str | None,
    maps_url: str | None,
    scan_time: datetime,
    responder_name: str | None = None,
) -> bool:
    """Send high-priority SOS emergency alert push notification to an emergency contact's device."""
    time_str = _ist_time(scan_time)
    area = location_area or "Unknown area"
    responder = responder_name or "First responder"

    try:
        from firebase_admin import messaging

        if not _ensure_firebase_initialized():
            return False

        message = messaging.Message(
            notification=messaging.Notification(
                title=f"🚨 EMERGENCY: {patient_name} Needs Help!",
                body=f"Medical QR scanned near {area} ({time_str}) by {responder}. Tap for GPS location.",
            ),
            data={
                "type": "emergency_sos",
                "patient_name": patient_name,
                "location_area": area,
                "maps_url": maps_url or "",
                "scan_time": time_str,
                "responder_name": responder,
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            },
            token=fcm_token,
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id="emergency_alerts",
                    priority="max",
                    default_sound=True,
                    default_vibrate_timings=True,
                    icon="ic_launcher",
                    color="#D32F2F",
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default", content_available=True)
                )
            ),
        )
        messaging.send(message)
        logger.info("FCM sent to emergency contact (token: %s…)", fcm_token[:12])
        return True
    except Exception as exc:
        logger.error("Emergency contact FCM exception: %s", exc)
        return False


# ── Email fallback via Resend ──────────────────────────────────────────────────

async def send_email_fallback(
    to_email: str | None,
    patient_name: str,
    scan_time: datetime,
    maps_url: str | None,
) -> bool:
    """Only called if SMS fails after all retries."""
    if not to_email:
        return False

    time_str = _ist_time(scan_time)
    location_link = f'<a href="{maps_url}">View Location</a>' if maps_url else "Location unavailable"

    html = f"""
    <h2>🔴 EMERGENCY ALERT — Golden Hour</h2>
    <p><strong>{patient_name}</strong>'s medical QR code was scanned.</p>
    <ul>
        <li><strong>Time:</strong> {time_str}</li>
        <li><strong>Location:</strong> {location_link}</li>
    </ul>
    <p>Please call 108 or rush to the location immediately.</p>
    <hr>
    <small>Powered by Golden Hour — Medical Emergency QR System</small>
    """

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                "https://api.resend.com/emails",
                headers={
                    "Authorization": f"Bearer {settings.resend_api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "from": settings.from_email,
                    "to": [to_email],
                    "subject": f"🔴 EMERGENCY: {patient_name}'s QR was scanned",
                    "html": html,
                },
                timeout=10,
            )
        if resp.status_code in (200, 201):
            logger.info("Email sent to %s", to_email)
            return True
        logger.warning("Email failed for %s: %s", to_email, resp.text)
        return False
    except Exception as exc:
        logger.error("Email exception for %s: %s", to_email, exc)
        return False

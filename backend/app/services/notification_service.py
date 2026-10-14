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


# ── WhatsApp via Green-API ────────────────────────────────────────────────────
 
async def send_whatsapp(
    phone: str,
    patient_name: str,
    scan_time: datetime,
    maps_url: str | None,
    responder_name: str | None,
) -> bool:
    """Send emergency alert via Green-API WhatsApp."""
    if not settings.green_api_instance_id or not settings.green_api_token:
        logger.warning("Green-API credentials not configured; skipping WhatsApp notification")
        return False

    time_str = _ist_time(scan_time)
    location = maps_url or "Location unavailable"
    responder = responder_name or "Unknown responder"

    # Green-API chatId format: <country_code><number>@c.us (e.g. 919876543210@c.us)
    clean_phone = phone.lstrip("+").strip()
    chat_id = f"{clean_phone}@c.us"

    message_text = (
        f"🚨 *EMERGENCY ALERT — Golden Hour*\n\n"
        f"*{patient_name}*'s medical emergency QR was just scanned.\n"
        f"⏰ *Time:* {time_str}\n"
        f"📍 *Location:* {location}\n"
        f"👤 *First Responder:* {responder}\n\n"
        f"Please call 108 or reach out immediately."
    )

    host = settings.green_api_host.rstrip("/")
    url = f"{host}/waInstance{settings.green_api_instance_id}/sendMessage/{settings.green_api_token}"

    payload = {
        "chatId": chat_id,
        "message": message_text,
    }

    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(
                url,
                json=payload,
                timeout=15,
            )
        if resp.status_code == 200:
            data = resp.json()
            if "idMessage" in data:
                logger.info("WhatsApp sent via Green-API to %s (id: %s)", phone, data["idMessage"])
                return True
        logger.warning("Green-API WhatsApp failed for %s: %s", phone, resp.text)
        return False
    except Exception as exc:
        logger.error("Green-API WhatsApp exception for %s: %s", phone, exc)
        return False


# ── FCM Push (to patient device) ──────────────────────────────────────────────

async def send_fcm_push(
    fcm_token: str,
    location_area: str | None,
    scan_time: datetime,
) -> bool:
    """Send FCM push notification to the patient's device."""
    time_str = _ist_time(scan_time)
    area = location_area or "Unknown area"

    try:
        import firebase_admin
        from firebase_admin import credentials, messaging

        # Initialise once
        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.firebase_credentials_json)
            firebase_admin.initialize_app(cred)

        message = messaging.Message(
            notification=messaging.Notification(
                title="⚠️ Your Medical QR Was Scanned",
                body=f"Scanned near {area}, {time_str}. Tap to view details.",
            ),
            token=fcm_token,
            android=messaging.AndroidConfig(priority="high"),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(content_available=True)
                )
            ),
        )
        messaging.send(message)
        logger.info("FCM sent to token %s…", fcm_token[:10])
        return True
    except Exception as exc:
        logger.error("FCM exception: %s", exc)
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

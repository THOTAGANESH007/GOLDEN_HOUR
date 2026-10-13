"""
QR service — UID generation, public scan handler.
"""
import random
import string
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.profile import Profile
from app.models.scan_event import ScanEvent
from app.models.user import User
from app.models.emergency_contact import EmergencyContact

settings = get_settings()

_UID_CHARS = string.ascii_uppercase + string.digits  # A-Z 0-9


def generate_uid(length: int = 8) -> str:
    """Generate a random 8-character alphanumeric UID."""
    return "".join(random.choices(_UID_CHARS, k=length))


async def _ensure_unique_uid(db: AsyncSession) -> str:
    """Keep generating until we get a UID not already in the DB."""
    for _ in range(10):
        uid = generate_uid()
        result = await db.execute(select(Profile).where(Profile.qr_uid == uid))
        if result.scalar_one_or_none() is None:
            return uid
    raise RuntimeError("Could not generate a unique QR UID after 10 attempts")


async def get_or_create_profile(db: AsyncSession, user: User) -> Profile:
    """Return existing profile or create a blank one."""
    if user.profile is not None:
        return user.profile

    result = await db.execute(select(Profile).where(Profile.user_id == user.id))
    profile = result.scalar_one_or_none()

    if profile is None:
        uid = await _ensure_unique_uid(db)
        profile = Profile(user_id=user.id, qr_uid=uid)
        db.add(profile)
        await db.flush()

    return profile


async def regenerate_qr(db: AsyncSession, profile: Profile) -> Profile:
    """Invalidate current UID, assign a new one."""
    profile.qr_uid = await _ensure_unique_uid(db)
    db.add(profile)
    return profile


async def get_profile_by_uid(db: AsyncSession, uid: str) -> Profile | None:
    result = await db.execute(
        select(Profile).where(Profile.qr_uid == uid, Profile.qr_is_active == True)  # noqa: E712
    )
    return result.scalar_one_or_none()


async def is_duplicate_scan(db: AsyncSession, uid: str) -> bool:
    """True if same UID scanned within the dedup window."""
    window = datetime.now(timezone.utc) - timedelta(
        minutes=settings.notification_dedup_minutes
    )
    result = await db.execute(
        select(ScanEvent).where(
            ScanEvent.qr_uid == uid,
            ScanEvent.scanned_at >= window,
            ScanEvent.notification_suppressed == False,  # noqa: E712
        )
    )
    return result.scalar_one_or_none() is not None


async def log_scan_event(
    db: AsyncSession,
    user_id: uuid.UUID,
    qr_uid: str,
    responder_name: str | None,
    responder_hospital: str | None,
    latitude: float | None,
    longitude: float | None,
    user_agent: str | None,
    suppressed: bool = False,
) -> ScanEvent:
    """Create and persist a scan event record."""
    device_type = _parse_device_type(user_agent)
    maps_url = None
    if latitude and longitude:
        maps_url = f"https://www.google.com/maps?q={latitude},{longitude}"

    event = ScanEvent(
        user_id=user_id,
        qr_uid=qr_uid,
        responder_name=responder_name,
        responder_hospital=responder_hospital,
        latitude=latitude,
        longitude=longitude,
        google_maps_url=maps_url,
        user_agent=user_agent,
        device_type=device_type,
        notification_suppressed=suppressed,
    )
    db.add(event)
    await db.flush()
    return event


def _parse_device_type(user_agent: str | None) -> str:
    if not user_agent:
        return "unknown"
    ua = user_agent.lower()
    if "mobile" in ua or "android" in ua or "iphone" in ua:
        return "mobile"
    if "tablet" in ua or "ipad" in ua:
        return "tablet"
    return "desktop"


async def get_safe_public_data(
    db: AsyncSession, profile: Profile, scan_event_id: uuid.UUID
) -> dict:
    """Build the safe dictionary returned to the responder web app."""
    # Fetch contacts
    result = await db.execute(
        select(EmergencyContact)
        .where(EmergencyContact.user_id == profile.user_id)
        .order_by(EmergencyContact.sort_order)
    )
    contacts = result.scalars().all()

    return {
        "full_name": profile.full_name if profile.show_name else None,
        "blood_group": profile.blood_group,
        "allergies": profile.allergies or [],
        "chronic_conditions": profile.chronic_conditions or [],
        "medications": profile.medications or [],
        "past_surgeries": profile.past_surgeries or [],
        "implants": profile.implants or [],
        "is_organ_donor": profile.is_organ_donor,
        "doctor_name": profile.doctor_name,
        "doctor_phone": profile.doctor_phone,
        "contacts": [
            {
                "name": c.name,
                "relation": c.relation,
                "phone": c.phone,
                "whatsapp_enabled": c.whatsapp_enabled,
            }
            for c in contacts
        ],
        "qr_uid": profile.qr_uid,
        "scan_event_id": str(scan_event_id),
    }

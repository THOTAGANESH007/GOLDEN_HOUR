"""
Auth service — JWT creation, verification, OTP via Supabase.
"""
import hashlib
import secrets
import uuid
from datetime import datetime, timedelta, timezone

import httpx
from jose import JWTError, jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.user import User

settings = get_settings()


# ── JWT helpers ────────────────────────────────────────────────────────────────

def _create_token(data: dict, expires_delta: timedelta) -> str:
    payload = data.copy()
    payload["exp"] = datetime.now(timezone.utc) + expires_delta
    payload["iat"] = datetime.now(timezone.utc)
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def create_access_token(user_id: uuid.UUID) -> str:
    return _create_token(
        {"sub": str(user_id), "type": "access"},
        timedelta(minutes=settings.access_token_expire_minutes),
    )


def create_refresh_token(user_id: uuid.UUID) -> str:
    return _create_token(
        {
            "sub": str(user_id),
            "type": "refresh",
            "jti": secrets.token_hex(16),    # unique per token
        },
        timedelta(days=settings.refresh_token_expire_days),
    )


def decode_token(token: str) -> dict:
    """Decode and validate a JWT. Raises JWTError on failure."""
    return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])


def hash_token(token: str) -> str:
    """SHA-256 hash stored server-side for refresh token revocation."""
    return hashlib.sha256(token.encode()).hexdigest()


# ── WhatsApp OTP via Redis ────────────────────────────────────────────────────

_in_memory_otp_cache: dict[str, tuple[str, datetime]] = {}


async def _get_redis_client():
    try:
        import redis.asyncio as aioredis
        client = aioredis.from_url(
            settings.redis_url,
            decode_responses=True,
            socket_timeout=3,
            socket_connect_timeout=3,
        )
        await client.ping()
        return client
    except Exception:
        return None


async def send_otp(phone: str) -> dict:
    """
    Generate 6-digit OTP, store in Redis with 10-min TTL, and dispatch via WhatsApp (or SMS safety net).
    """
    clean_phone = phone.lstrip("+").strip()
    otp_code = f"{secrets.randbelow(1000000):06d}"

    # 1. Store in Redis with 10-minute expiry (TTL 600s)
    stored = False
    redis_client = await _get_redis_client()
    if redis_client:
        try:
            await redis_client.set(f"otp:{clean_phone}", otp_code, ex=600)
            await redis_client.aclose()
            stored = True
        except Exception:
            pass

    if not stored:
        _in_memory_otp_cache[clean_phone] = (
            otp_code,
            datetime.now(timezone.utc) + timedelta(minutes=10),
        )

    # 2. Dispatch via WhatsApp
    from app.services.notification_service import send_custom_whatsapp, send_custom_sms

    whatsapp_msg = (
        f"🔐 *Golden Hour Sign-In Code*\n\n"
        f"Your verification code is: *{otp_code}*\n\n"
        f"⏰ Valid for 10 minutes. Do not share this code with anyone."
    )
    sent = await send_custom_whatsapp(phone, whatsapp_msg, otp_code=otp_code)

    # 3. Fallback to SMS if WhatsApp delivery failed or unconfigured
    if not sent:
        sms_msg = f"Golden Hour sign-in code: {otp_code}. Valid for 10 minutes."
        await send_custom_sms(phone, sms_msg)

    return {"status": "success", "message": "OTP dispatched successfully"}


async def verify_otp(phone: str, otp: str) -> dict:
    """
    Verify 6-digit OTP code against Redis / cache.
    Raises ValueError on invalid or expired OTP.
    """
    clean_phone = phone.lstrip("+").strip()
    target_otp = otp.strip()

    stored_otp = None
    redis_client = await _get_redis_client()
    if redis_client:
        try:
            stored_otp = await redis_client.get(f"otp:{clean_phone}")
            if stored_otp:
                await redis_client.delete(f"otp:{clean_phone}")
            await redis_client.aclose()
        except Exception:
            pass

    if not stored_otp and clean_phone in _in_memory_otp_cache:
        val, expiry = _in_memory_otp_cache.pop(clean_phone)
        if datetime.now(timezone.utc) <= expiry:
            stored_otp = val

    if not stored_otp or stored_otp != target_otp:
        raise ValueError("Invalid or expired OTP code")

    return {"status": "verified"}


# ── User DB helpers ────────────────────────────────────────────────────────────

async def get_or_create_user(db: AsyncSession, phone: str, consent_given: bool = False) -> User:
    """Fetch existing user by phone, or create a new one."""
    result = await db.execute(select(User).where(User.phone == phone))
    user = result.scalar_one_or_none()

    if user is None:
        user = User(
            phone=phone,
            consent_given=consent_given,
            consent_timestamp=datetime.now(timezone.utc) if consent_given else None,
        )
        db.add(user)
        await db.flush()  # get the id without committing

    return user


async def get_user_by_id(db: AsyncSession, user_id: uuid.UUID) -> User | None:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


async def store_refresh_token(db: AsyncSession, user: User, refresh_token: str) -> None:
    """Hash and store refresh token for server-side revocation."""
    user.refresh_token_hash = hash_token(refresh_token)
    db.add(user)


async def revoke_refresh_token(db: AsyncSession, user: User) -> None:
    """Clear stored hash — effectively logs out the user."""
    user.refresh_token_hash = None
    db.add(user)


# ── Google & Firebase Token Verification ───────────────────────────────────────

def verify_google_id_token(id_token_str: str) -> dict:
    """
    Verify Google ID token or Firebase ID token.
    Returns payload with 'sub', 'email', and optional 'name', 'picture'.
    """
    # 1. Try Google OAuth2 token verification
    try:
        from google.auth.transport import requests
        from google.oauth2 import id_token

        id_info = id_token.verify_oauth2_token(id_token_str, requests.Request())
        return {
            "sub": id_info.get("sub"),
            "email": id_info.get("email"),
            "name": id_info.get("name"),
            "picture": id_info.get("picture"),
        }
    except Exception as exc_google:
        # 2. Try Firebase ID token verification if applicable
        try:
            import firebase_admin
            from firebase_admin import auth as fb_auth

            if not firebase_admin._apps:
                firebase_admin.initialize_app()

            decoded_fb = fb_auth.verify_id_token(id_token_str)
            return {
                "sub": decoded_fb.get("uid"),
                "email": decoded_fb.get("email"),
                "name": decoded_fb.get("name"),
                "picture": decoded_fb.get("picture"),
            }
        except Exception:
            raise ValueError(f"Invalid Google / Firebase ID token: {exc_google}")


async def get_or_create_google_user(
    db: AsyncSession,
    google_id: str,
    email: str,
) -> tuple[User, bool]:
    """
    Fetch existing user by google_id or email, or create a new user.
    Returns (user, is_new_user).
    """
    from sqlalchemy import or_

    result = await db.execute(
        select(User).where(or_(User.google_id == google_id, User.email == email))
    )
    user = result.scalar_one_or_none()
    is_new = False

    if user is None:
        is_new = True
        user = User(
            google_id=google_id,
            email=email,
            consent_given=True,
            consent_timestamp=datetime.now(timezone.utc),
        )
        db.add(user)
        await db.flush()
    else:
        # Link google_id or email if missing
        updated = False
        if not user.google_id:
            user.google_id = google_id
            updated = True
        if not user.email:
            user.email = email
            updated = True
        if updated:
            db.add(user)

    return user, is_new


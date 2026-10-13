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


# ── Supabase OTP ───────────────────────────────────────────────────────────────

SUPABASE_AUTH_URL = f"{settings.supabase_url}/auth/v1"
SUPABASE_HEADERS = {
    "apikey": settings.supabase_service_key,
    "Content-Type": "application/json",
}


async def send_otp(phone: str) -> dict:
    """
    Ask Supabase to send an OTP SMS to the given phone number.
    Returns the raw Supabase response.
    """
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{SUPABASE_AUTH_URL}/otp",
            headers=SUPABASE_HEADERS,
            json={"phone": phone, "channel": "sms"},
            timeout=10,
        )
    resp.raise_for_status()
    return resp.json()


async def verify_otp(phone: str, otp: str) -> dict:
    """
    Verify the OTP with Supabase. Returns Supabase session data on success.
    Raises httpx.HTTPStatusError on wrong OTP.
    """
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{SUPABASE_AUTH_URL}/verify",
            headers=SUPABASE_HEADERS,
            json={"phone": phone, "token": otp, "type": "sms"},
            timeout=10,
        )
    resp.raise_for_status()
    return resp.json()


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

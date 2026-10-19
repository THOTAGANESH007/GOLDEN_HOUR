"""
Auth endpoints: send-otp, verify-otp, refresh, logout, delete-account,
and FCM token update.
"""
import logging
import uuid
from datetime import datetime, timezone

import sentry_sdk
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.profile import Profile
from app.models.user import User
from app.schemas.auth import (
    FCMTokenUpdate,
    RefreshRequest,
    SendOTPRequest,
    TokenResponse,
    VerifyOTPRequest,
)
from app.services import auth_service
from app.services.qr_service import get_or_create_profile

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["Authentication"])


# ── POST /auth/send-otp ────────────────────────────────────────────────────────

@router.post("/send-otp", status_code=status.HTTP_200_OK)
async def send_otp(body: SendOTPRequest, db: AsyncSession = Depends(get_db)):
    """Send an OTP SMS to the given phone number via Supabase Auth."""
    try:
        await auth_service.send_otp(body.phone)
    except Exception as exc:
        logger.error(f"OTP send failed for {body.phone}: {exc}")
        sentry_sdk.capture_exception(exc)
        raise HTTPException(status_code=502, detail=f"OTP send failed: {exc}")
    return {"message": "OTP sent successfully"}


# ── POST /auth/verify-otp ──────────────────────────────────────────────────────

@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(body: VerifyOTPRequest, db: AsyncSession = Depends(get_db)):
    """Verify OTP → return JWT access + refresh tokens. Creates user if first login."""
    try:
        await auth_service.verify_otp(body.phone, body.otp)
    except Exception as exc:
        logger.error(f"OTP verification failed for {body.phone}: {exc}")
        sentry_sdk.capture_exception(exc)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid OTP"
        )

    user = await auth_service.get_or_create_user(db, body.phone)

    # Auto-create blank profile + QR UID on first login
    await get_or_create_profile(db, user)

    access_token = auth_service.create_access_token(user.id)
    refresh_token = auth_service.create_refresh_token(user.id)
    await auth_service.store_refresh_token(db, user, refresh_token)

    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


# ── POST /auth/refresh ─────────────────────────────────────────────────────────

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    """Rotate refresh token → new access + refresh token pair."""
    from jose import JWTError
    credentials_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
    )
    try:
        payload = auth_service.decode_token(body.refresh_token)
        if payload.get("type") != "refresh":
            raise credentials_exc
        user_id = uuid.UUID(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise credentials_exc

    user = await auth_service.get_user_by_id(db, user_id)
    if user is None:
        raise credentials_exc

    # Verify the token hash matches what we stored (revocation check)
    stored_hash = user.refresh_token_hash
    if stored_hash != auth_service.hash_token(body.refresh_token):
        raise credentials_exc

    new_access = auth_service.create_access_token(user.id)
    new_refresh = auth_service.create_refresh_token(user.id)
    await auth_service.store_refresh_token(db, user, new_refresh)

    return TokenResponse(access_token=new_access, refresh_token=new_refresh)


# ── POST /auth/logout ──────────────────────────────────────────────────────────

@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Revoke server-side refresh token — user must log in again."""
    await auth_service.revoke_refresh_token(db, current_user)
    return None


# ── DELETE /auth/delete-account ────────────────────────────────────────────────

@router.delete("/delete-account", status_code=status.HTTP_204_NO_CONTENT)
async def delete_account(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    DPDPA right to erasure — hard delete all user data.
    CASCADE on the DB handles contacts, profile, documents, scan events.
    """
    await db.delete(current_user)
    return None


# ── PATCH /auth/fcm-token ──────────────────────────────────────────────────────

@router.patch("/fcm-token", status_code=status.HTTP_200_OK)
async def update_fcm_token(
    body: FCMTokenUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Register / update the device FCM token for push notifications."""
    current_user.fcm_token = body.fcm_token
    db.add(current_user)
    return {"message": "FCM token updated"}

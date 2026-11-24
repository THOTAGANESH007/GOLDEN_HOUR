"""
Notification endpoints: history, false alarm, test send.
"""
import logging
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.scan_event import ScanEvent
from app.models.user import User
from app.schemas.notification import (
    CATEGORY_EMERGENCY_SOS,
    VALID_CATEGORIES,
    PushNotificationRequest,
    PushNotificationResponse,
)
from app.schemas.scan_event import ScanEventListResponse, ScanEventResponse
from app.services.notification_service import send_enhanced_push

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("/history", response_model=ScanEventListResponse)
async def get_notification_history(
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Paginated scan + notification history for the patient."""
    offset = (page - 1) * page_size

    count_result = await db.execute(
        select(ScanEvent).where(ScanEvent.user_id == current_user.id)
    )
    total = len(count_result.scalars().all())

    result = await db.execute(
        select(ScanEvent)
        .where(ScanEvent.user_id == current_user.id)
        .order_by(ScanEvent.scanned_at.desc())
        .offset(offset)
        .limit(page_size)
    )
    items = result.scalars().all()

    return ScanEventListResponse(
        items=items, total=total, page=page, page_size=page_size
    )


@router.post("/false-alarm/{scan_id}", status_code=status.HTTP_200_OK)
async def mark_false_alarm(
    scan_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Mark a scan event as a false alarm."""
    result = await db.execute(
        select(ScanEvent).where(
            ScanEvent.id == scan_id, ScanEvent.user_id == current_user.id
        )
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Scan event not found")

    event.is_false_alarm = True
    db.add(event)
    return {"message": "Marked as false alarm"}


@router.post("/test", status_code=status.HTTP_200_OK)
async def send_test_notification(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Send a test SMS and WhatsApp to the patient's own phone number."""
    from datetime import datetime, timezone
    from app.services.notification_service import send_whatsapp

    now = datetime.now(timezone.utc)
    wa_ok = await send_whatsapp(
        phone=current_user.phone,
        patient_name="Test Patient",
        scan_time=now,
        maps_url=None,
        responder_name="Golden Hour Test",
    )

    return {
        "whatsapp_sent": wa_ok,
        "message": "Test notification dispatched",
    }


@router.post("/push", response_model=PushNotificationResponse, status_code=status.HTTP_200_OK)
async def dispatch_push_notification(
    req: PushNotificationRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Dispatch enhanced push notification (SOS, safety tip, app update, or radar alert).
    Supports category targeting, data-only background sync, and analytics logging.
    """
    category = req.category if req.category in VALID_CATEGORIES else CATEGORY_EMERGENCY_SOS
    tokens: list[str] = list(req.fcm_tokens or [])

    if req.target_user_ids:
        try:
            target_uuids = [uuid.UUID(uid) for uid in req.target_user_ids]
            stmt = select(User.fcm_token).where(
                User.id.in_(target_uuids),
                User.fcm_token.isnot(None),
            )
            res = await db.execute(stmt)
            fetched_tokens = [t for t in res.scalars().all() if t]
            tokens.extend(fetched_tokens)
        except Exception:
            pass

    if not tokens:
        if current_user.fcm_token:
            tokens.append(current_user.fcm_token)
        else:
            tokens.append("test_fcm_token_device")

    tokens = list(set(tokens))
    success, failure = await send_enhanced_push(
        fcm_tokens=tokens,
        title=req.title,
        body=req.body,
        category=category,
        custom_data=req.data,
        is_data_only=req.is_data_only,
    )

    now_iso = datetime.now(timezone.utc).isoformat()
    logger.info(
        "analytics_event=notification_sent category=%s recipients=%d success=%d failure=%d is_data_only=%s",
        category,
        len(tokens),
        success,
        failure,
        req.is_data_only,
    )

    return PushNotificationResponse(
        status="success",
        message=f"Push notification dispatched ({success} succeeded, {failure} failed)",
        success_count=success,
        failure_count=failure,
        category=category,
        is_data_only=req.is_data_only,
        analytics_event="notification_sent",
        dispatched_at=now_iso,
    )


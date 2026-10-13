"""
Notification endpoints: history, false alarm, test send.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.scan_event import ScanEvent
from app.models.user import User
from app.schemas.scan_event import ScanEventListResponse, ScanEventResponse

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
    from app.services.notification_service import send_sms, send_whatsapp

    now = datetime.now(timezone.utc)
    sms_ok = await send_sms(
        phone=current_user.phone,
        patient_name="Test Patient",
        scan_time=now,
        maps_url=None,
        responder_name="Golden Hour Test",
    )
    wa_ok = await send_whatsapp(
        phone=current_user.phone,
        patient_name="Test Patient",
        scan_time=now,
        maps_url=None,
        responder_name="Golden Hour Test",
    )

    return {
        "sms_sent": sms_ok,
        "whatsapp_sent": wa_ok,
        "message": "Test notification dispatched",
    }

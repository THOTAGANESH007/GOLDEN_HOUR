"""
Scan Events endpoints: paginated list, single detail, false-alarm flag.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.scan_event import ScanEvent
from app.models.user import User
from app.schemas.scan_event import ScanEventListResponse, ScanEventResponse

router = APIRouter(prefix="/scan-events", tags=["Scan History"])


@router.get("", response_model=ScanEventListResponse)
async def list_scan_events(
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    offset = (page - 1) * page_size

    total_result = await db.execute(
        select(func.count()).select_from(ScanEvent).where(ScanEvent.user_id == current_user.id)
    )
    total = total_result.scalar_one()

    result = await db.execute(
        select(ScanEvent)
        .where(ScanEvent.user_id == current_user.id)
        .order_by(ScanEvent.scanned_at.desc())
        .offset(offset)
        .limit(page_size)
    )
    items = result.scalars().all()

    return ScanEventListResponse(items=items, total=total, page=page, page_size=page_size)


@router.get("/{scan_id}", response_model=ScanEventResponse)
async def get_scan_event(
    scan_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ScanEvent).where(
            ScanEvent.id == scan_id, ScanEvent.user_id == current_user.id
        )
    )
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Scan event not found")
    return event


@router.patch("/{scan_id}/false-alarm", response_model=ScanEventResponse)
async def flag_false_alarm(
    scan_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
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
    return event

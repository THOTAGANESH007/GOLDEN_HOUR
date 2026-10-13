import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.schemas.document import DocumentResponse  # noqa: F401


class ScanEventResponse(BaseModel):
    id: uuid.UUID
    qr_uid: str
    responder_name: Optional[str] = None
    responder_hospital: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    location_area: Optional[str] = None
    google_maps_url: Optional[str] = None
    device_type: Optional[str] = None
    sms_sent: bool
    whatsapp_sent: bool
    fcm_sent: bool
    email_sent: bool
    notification_suppressed: bool
    is_false_alarm: bool
    scanned_at: datetime

    model_config = {"from_attributes": True}


class ScanEventListResponse(BaseModel):
    items: list[ScanEventResponse]
    total: int
    page: int
    page_size: int

import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.schemas.profile import EmergencyContactResponse


class ContactGroupBase(BaseModel):
    name: str
    description: Optional[str] = None


class ContactGroupCreate(ContactGroupBase):
    pass


class ContactGroupUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None


class ContactGroupResponse(ContactGroupBase):
    id: uuid.UUID
    user_id: uuid.UUID
    contact_count: int = 0
    contacts: list[EmergencyContactResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class GroupBroadcastRequest(BaseModel):
    group_id: Optional[uuid.UUID] = None  # None = broadcast to all user's contacts
    message: Optional[str] = None
    location_lat: Optional[float] = None
    location_lng: Optional[float] = None
    location_address: Optional[str] = None


class BroadcastRecipientStatus(BaseModel):
    contact_id: uuid.UUID
    name: str
    phone: str
    whatsapp_sent: bool
    fcm_sent: bool


class GroupBroadcastResponse(BaseModel):
    broadcast_id: str
    group_id: Optional[uuid.UUID] = None
    group_name: Optional[str] = None
    total_contacts: int
    whatsapp_sent_count: int
    fcm_sent_count: int
    recipients: list[BroadcastRecipientStatus]
    sent_at: datetime


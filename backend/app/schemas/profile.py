import uuid
from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, field_validator
import re


# ── Emergency Contact Schemas ──────────────────────────────────────────────────

class EmergencyContactBase(BaseModel):
    name: str
    relation: str
    phone: str              # E.164
    whatsapp_enabled: bool = True
    notify_on_scan: bool = True
    sort_order: int = 0

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not v:
            raise ValueError("Phone number cannot be empty")
        cleaned = re.sub(r"[\s\-\(\)]", "", v.strip())
        if cleaned.startswith("00"):
            cleaned = "+" + cleaned[2:]
        elif cleaned.startswith("0") and len(cleaned) == 11:
            cleaned = "+91" + cleaned[1:]
        elif not cleaned.startswith("+"):
            if len(cleaned) == 10:
                cleaned = "+91" + cleaned
            else:
                cleaned = "+" + cleaned
        if not re.match(r"^\+\d{10,15}$", cleaned):
            raise ValueError("Phone must be in E.164 format e.g. +91XXXXXXXXXX or a valid 10-digit number")
        return cleaned


class EmergencyContactCreate(EmergencyContactBase):
    pass


class EmergencyContactUpdate(BaseModel):
    name: Optional[str] = None
    relation: Optional[str] = None
    phone: Optional[str] = None
    whatsapp_enabled: Optional[bool] = None
    notify_on_scan: Optional[bool] = None
    sort_order: Optional[int] = None

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        cleaned = re.sub(r"[\s\-\(\)]", "", v.strip())
        if cleaned.startswith("00"):
            cleaned = "+" + cleaned[2:]
        elif cleaned.startswith("0") and len(cleaned) == 11:
            cleaned = "+91" + cleaned[1:]
        elif not cleaned.startswith("+"):
            if len(cleaned) == 10:
                cleaned = "+91" + cleaned
            else:
                cleaned = "+" + cleaned
        if not re.match(r"^\+\d{10,15}$", cleaned):
            raise ValueError("Phone must be in E.164 format e.g. +91XXXXXXXXXX or a valid 10-digit number")
        return cleaned


class EmergencyContactResponse(EmergencyContactBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Medication Item ────────────────────────────────────────────────────────────

class MedicationItem(BaseModel):
    name: str
    dosage: str
    frequency: str


# ── Profile Schemas ────────────────────────────────────────────────────────────

class ProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    blood_group: Optional[str] = None
    allergies: Optional[list[str]] = None
    chronic_conditions: Optional[list[str]] = None
    medications: Optional[list[MedicationItem]] = None
    past_surgeries: Optional[list[str]] = None
    implants: Optional[list[str]] = None
    is_organ_donor: Optional[bool] = None
    doctor_name: Optional[str] = None
    doctor_phone: Optional[str] = None
    wizard_completed: Optional[bool] = None


class PrivacyUpdate(BaseModel):
    show_name: Optional[bool] = None
    show_dob: Optional[bool] = None
    show_photo: Optional[bool] = None


class QRStatusUpdate(BaseModel):
    qr_is_active: bool


class ProfileResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    qr_uid: Optional[str] = None
    qr_is_active: bool
    full_name: Optional[str] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    photo_url: Optional[str] = None
    blood_group: Optional[str] = None
    allergies: Optional[list[str]] = None
    chronic_conditions: Optional[list[str]] = None
    medications: Optional[list[dict]] = None
    past_surgeries: Optional[list[str]] = None
    implants: Optional[list[str]] = None
    is_organ_donor: bool
    doctor_name: Optional[str] = None
    doctor_phone: Optional[str] = None
    show_name: bool
    show_dob: bool
    show_photo: bool
    wizard_completed: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ProfileCompletionResponse(BaseModel):
    """Returned alongside profile — shows % completion."""
    score: int       # 0-100
    missing: list[str]   # List of field names not yet filled


# ── Public Profile (no-auth, for responder web) ────────────────────────────────

class PublicProfileResponse(BaseModel):
    """Safe subset of profile data shown on responder page."""
    full_name: Optional[str] = None       # only if show_name=True
    blood_group: Optional[str] = None
    allergies: Optional[list[str]] = None
    chronic_conditions: Optional[list[str]] = None
    medications: Optional[list[dict]] = None
    past_surgeries: Optional[list[str]] = None
    implants: Optional[list[str]] = None
    is_organ_donor: bool
    doctor_name: Optional[str] = None
    doctor_phone: Optional[str] = None
    contacts: list[dict]    # [{ name, relation, phone, whatsapp_enabled }]
    qr_uid: str
    scan_event_id: str      # for false-alarm reporting

    model_config = {"from_attributes": False}

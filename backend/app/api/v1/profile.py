"""
Profile endpoints: CRUD for patient profile, privacy, contacts, QR status.
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.emergency_contact import EmergencyContact
from app.models.profile import Profile
from app.models.user import User
from app.schemas.profile import (
    EmergencyContactCreate,
    EmergencyContactResponse,
    EmergencyContactUpdate,
    PrivacyUpdate,
    ProfileCompletionResponse,
    ProfileResponse,
    ProfileUpdate,
    QRStatusUpdate,
)
from app.services.qr_service import get_or_create_profile

router = APIRouter(prefix="/profile", tags=["Profile"])


# ── Helpers ────────────────────────────────────────────────────────────────────

def _completion_score(profile: Profile) -> ProfileCompletionResponse:
    fields = {
        "blood_group": profile.blood_group,
        "full_name": profile.full_name,
        "date_of_birth": profile.date_of_birth,
        "gender": profile.gender,
        "allergies": profile.allergies,
        "chronic_conditions": profile.chronic_conditions,
        "medications": profile.medications,
        "emergency_contacts": None,   # checked separately
    }
    missing = [k for k, v in fields.items() if not v]
    filled = len(fields) - len(missing)
    score = int((filled / len(fields)) * 100)
    return ProfileCompletionResponse(score=score, missing=missing)


async def _get_profile(db: AsyncSession, user: User) -> Profile:
    result = await db.execute(select(Profile).where(Profile.user_id == user.id))
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile


# ── GET /profile/me ────────────────────────────────────────────────────────────

@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    profile = await get_or_create_profile(db, current_user)
    return profile


# ── PUT /profile/me ────────────────────────────────────────────────────────────

@router.put("/me", response_model=ProfileResponse)
async def update_profile(
    body: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    profile = await _get_profile(db, current_user)
    update_data = body.model_dump(exclude_unset=True)

    # Convert MedicationItem list → plain dicts for JSON column
    if "medications" in update_data and update_data["medications"]:
        update_data["medications"] = [
            m if isinstance(m, dict) else m.model_dump()
            for m in update_data["medications"]
        ]

    for field, value in update_data.items():
        setattr(profile, field, value)

    db.add(profile)
    return profile


# ── PATCH /profile/me/privacy ──────────────────────────────────────────────────

@router.patch("/me/privacy", response_model=ProfileResponse)
async def update_privacy(
    body: PrivacyUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    profile = await _get_profile(db, current_user)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(profile, field, value)
    db.add(profile)
    return profile


# ── PATCH /profile/me/status ───────────────────────────────────────────────────

@router.patch("/me/status", response_model=ProfileResponse)
async def update_qr_status(
    body: QRStatusUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    profile = await _get_profile(db, current_user)
    profile.qr_is_active = body.qr_is_active
    db.add(profile)
    return profile


# ── GET /profile/completion ────────────────────────────────────────────────────

@router.get("/completion", response_model=ProfileCompletionResponse)
async def get_completion(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    profile = await _get_profile(db, current_user)
    return _completion_score(profile)


# ── Emergency Contacts ─────────────────────────────────────────────────────────

@router.get("/contacts", response_model=list[EmergencyContactResponse])
async def list_contacts(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(EmergencyContact)
        .where(EmergencyContact.user_id == current_user.id)
        .order_by(EmergencyContact.sort_order)
    )
    return result.scalars().all()


@router.post(
    "/contacts",
    response_model=EmergencyContactResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_contact(
    body: EmergencyContactCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Enforce max 5 contacts
    result = await db.execute(
        select(EmergencyContact).where(EmergencyContact.user_id == current_user.id)
    )
    existing = result.scalars().all()
    if len(existing) >= 5:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 5 emergency contacts allowed",
        )

    contact = EmergencyContact(user_id=current_user.id, **body.model_dump())
    db.add(contact)
    await db.flush()
    return contact


@router.put("/contacts/{contact_id}", response_model=EmergencyContactResponse)
async def update_contact(
    contact_id: uuid.UUID,
    body: EmergencyContactUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(EmergencyContact).where(
            EmergencyContact.id == contact_id,
            EmergencyContact.user_id == current_user.id,
        )
    )
    contact = result.scalar_one_or_none()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact not found")

    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(contact, field, value)
    db.add(contact)
    return contact


@router.delete("/contacts/{contact_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_contact(
    contact_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(EmergencyContact).where(
            EmergencyContact.id == contact_id,
            EmergencyContact.user_id == current_user.id,
        )
    )
    contact = result.scalar_one_or_none()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact not found")
    await db.delete(contact)
    return None

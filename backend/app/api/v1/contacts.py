"""
Contact Groups & Emergency Broadcast Endpoints.
"""
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.contact_group import ContactGroup
from app.models.emergency_contact import EmergencyContact
from app.models.profile import Profile
from app.models.user import User
from app.schemas.contact_group import (
    BroadcastRecipientStatus,
    ContactGroupCreate,
    ContactGroupResponse,
    ContactGroupUpdate,
    GroupBroadcastRequest,
    GroupBroadcastResponse,
)
from app.schemas.profile import EmergencyContactResponse
from app.services.analytics_service import analytics_service
from app.services.notification_service import send_custom_whatsapp

router = APIRouter(prefix="/contacts", tags=["Contacts & Groups"])


def _format_group_response(group: ContactGroup) -> ContactGroupResponse:
    contacts = group.contacts or []
    contact_responses = [
        EmergencyContactResponse(
            id=c.id,
            user_id=c.user_id,
            name=c.name,
            relation=c.relation,
            phone=c.phone,
            whatsapp_enabled=c.whatsapp_enabled,
            notify_on_scan=c.notify_on_scan,
            sort_order=c.sort_order,
            group_id=c.group_id,
            created_at=c.created_at,
        )
        for c in contacts
    ]
    return ContactGroupResponse(
        id=group.id,
        user_id=group.user_id,
        name=group.name,
        description=group.description,
        contact_count=len(contacts),
        contacts=contact_responses,
        created_at=group.created_at,
        updated_at=group.updated_at,
    )


# ── GET /contacts/groups ───────────────────────────────────────────────────────

@router.get("/groups", response_model=list[ContactGroupResponse])
async def list_contact_groups(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ContactGroup)
        .where(ContactGroup.user_id == current_user.id)
        .options(selectinload(ContactGroup.contacts))
        .order_by(ContactGroup.created_at.asc())
    )
    groups = result.scalars().all()
    return [_format_group_response(g) for g in groups]


# ── POST /contacts/groups ──────────────────────────────────────────────────────

@router.post(
    "/groups",
    response_model=ContactGroupResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_contact_group(
    body: ContactGroupCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Check max groups limit (e.g., 10 groups)
    count_res = await db.execute(
        select(func.count(ContactGroup.id)).where(ContactGroup.user_id == current_user.id)
    )
    if (count_res.scalar_one() or 0) >= 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 10 contact groups allowed per user",
        )

    # Check for duplicate group name
    dup_res = await db.execute(
        select(ContactGroup).where(
            ContactGroup.user_id == current_user.id,
            func.lower(ContactGroup.name) == body.name.strip().lower(),
        )
    )
    if dup_res.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Group with name '{body.name}' already exists",
        )

    group = ContactGroup(
        user_id=current_user.id,
        name=body.name.strip(),
        description=body.description.strip() if body.description else None,
    )
    db.add(group)
    await db.flush()
    await db.refresh(group, attribute_names=["contacts"])
    return _format_group_response(group)


# ── GET /contacts/groups/{group_id} ────────────────────────────────────────────

@router.get("/groups/{group_id}", response_model=ContactGroupResponse)
async def get_contact_group(
    group_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ContactGroup)
        .where(
            ContactGroup.id == group_id,
            ContactGroup.user_id == current_user.id,
        )
        .options(selectinload(ContactGroup.contacts))
    )
    group = result.scalar_one_or_none()
    if not group:
        raise HTTPException(status_code=404, detail="Contact group not found")
    return _format_group_response(group)


# ── PUT /contacts/groups/{group_id} ────────────────────────────────────────────

@router.put("/groups/{group_id}", response_model=ContactGroupResponse)
async def update_contact_group(
    group_id: uuid.UUID,
    body: ContactGroupUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ContactGroup)
        .where(
            ContactGroup.id == group_id,
            ContactGroup.user_id == current_user.id,
        )
        .options(selectinload(ContactGroup.contacts))
    )
    group = result.scalar_one_or_none()
    if not group:
        raise HTTPException(status_code=404, detail="Contact group not found")

    if body.name is not None:
        group.name = body.name.strip()
    if body.description is not None:
        group.description = body.description.strip() if body.description else None

    db.add(group)
    await db.flush()
    return _format_group_response(group)


# ── DELETE /contacts/groups/{group_id} ─────────────────────────────────────────

@router.delete("/groups/{group_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_contact_group(
    group_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ContactGroup).where(
            ContactGroup.id == group_id,
            ContactGroup.user_id == current_user.id,
        )
    )
    group = result.scalar_one_or_none()
    if not group:
        raise HTTPException(status_code=404, detail="Contact group not found")

    # Unlink contacts from this group
    contacts_res = await db.execute(
        select(EmergencyContact).where(EmergencyContact.group_id == group_id)
    )
    for c in contacts_res.scalars().all():
        c.group_id = None
        db.add(c)

    await db.delete(group)
    return None


# ── POST /contacts/groups/{group_id}/members/{contact_id} ─────────────────────

@router.post("/groups/{group_id}/members/{contact_id}", response_model=ContactGroupResponse)
async def add_contact_to_group(
    group_id: uuid.UUID,
    contact_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Verify group exists and belongs to user
    g_res = await db.execute(
        select(ContactGroup)
        .where(
            ContactGroup.id == group_id,
            ContactGroup.user_id == current_user.id,
        )
        .options(selectinload(ContactGroup.contacts))
    )
    group = g_res.scalar_one_or_none()
    if not group:
        raise HTTPException(status_code=404, detail="Contact group not found")

    # Verify contact exists and belongs to user
    c_res = await db.execute(
        select(EmergencyContact).where(
            EmergencyContact.id == contact_id,
            EmergencyContact.user_id == current_user.id,
        )
    )
    contact = c_res.scalar_one_or_none()
    if not contact:
        raise HTTPException(status_code=404, detail="Emergency contact not found")

    contact.group_id = group_id
    db.add(contact)
    await db.flush()

    # Re-fetch group with updated contacts
    await db.refresh(group, attribute_names=["contacts"])
    return _format_group_response(group)


# ── DELETE /contacts/groups/{group_id}/members/{contact_id} ───────────────────

@router.delete("/contacts/groups/{group_id}/members/{contact_id}", response_model=ContactGroupResponse)
async def remove_contact_from_group(
    group_id: uuid.UUID,
    contact_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    g_res = await db.execute(
        select(ContactGroup)
        .where(
            ContactGroup.id == group_id,
            ContactGroup.user_id == current_user.id,
        )
        .options(selectinload(ContactGroup.contacts))
    )
    group = g_res.scalar_one_or_none()
    if not group:
        raise HTTPException(status_code=404, detail="Contact group not found")

    c_res = await db.execute(
        select(EmergencyContact).where(
            EmergencyContact.id == contact_id,
            EmergencyContact.user_id == current_user.id,
            EmergencyContact.group_id == group_id,
        )
    )
    contact = c_res.scalar_one_or_none()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact not found in this group")

    contact.group_id = None
    db.add(contact)
    await db.flush()

    await db.refresh(group, attribute_names=["contacts"])
    return _format_group_response(group)


# ── POST /contacts/broadcast ───────────────────────────────────────────────────

@router.post("/broadcast", response_model=GroupBroadcastResponse)
async def broadcast_emergency_alert(
    body: GroupBroadcastRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Broadcasts an instant emergency safety alert to all members of a group
    (or all user emergency contacts if group_id is null).
    """
    # Fetch user's profile to obtain user full name
    prof_res = await db.execute(
        select(Profile).where(Profile.user_id == current_user.id)
    )
    profile = prof_res.scalar_one_or_none()
    user_name = profile.full_name if profile and profile.full_name else (current_user.phone or "Golden Hour User")

    # Determine target contacts
    group_name = None
    query = select(EmergencyContact).where(EmergencyContact.user_id == current_user.id)
    if body.group_id:
        g_res = await db.execute(
            select(ContactGroup).where(
                ContactGroup.id == body.group_id,
                ContactGroup.user_id == current_user.id,
            )
        )
        target_group = g_res.scalar_one_or_none()
        if not target_group:
            raise HTTPException(status_code=404, detail="Specified contact group not found")
        group_name = target_group.name
        query = query.where(EmergencyContact.group_id == body.group_id)

    res = await db.execute(query.order_by(EmergencyContact.sort_order))
    contacts = res.scalars().all()

    if not contacts:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No emergency contacts found for broadcast",
        )

    broadcast_id = f"bcast_{uuid.uuid4().hex[:12]}"
    now_utc = datetime.now(timezone.utc)

    # Build emergency message
    loc_info = ""
    if body.location_address:
        loc_info = f"\n📍 Location: {body.location_address}"
    elif body.location_lat and body.location_lng:
        maps_link = f"https://maps.google.com/?q={body.location_lat},{body.location_lng}"
        loc_info = f"\n📍 GPS Location: {maps_link}"

    custom_note = f"\n\nMessage: {body.message}" if body.message else ""

    alert_text = (
        f"🚨 EMERGENCY ALERT from {user_name} (Golden Hour Safety ID) 🚨\n\n"
        f"{user_name} has triggered an urgent emergency broadcast to their safety contacts."
        f"{custom_note}"
        f"{loc_info}\n\n"
        f"Time: {now_utc.strftime('%d %b %Y, %I:%M %p UTC')}\n"
        f"Please check in or reach out immediately."
    )

    recipients_status: list[BroadcastRecipientStatus] = []
    whatsapp_count = 0
    fcm_count = 0

    for c in contacts:
        wa_sent = False
        fcm_sent = False

        if c.whatsapp_enabled:
            try:
                wa_sent = await send_custom_whatsapp(c.phone, alert_text)
                if wa_sent:
                    whatsapp_count += 1
            except Exception:
                wa_sent = False

        # Attempt FCM if contact phone maps to a registered user with FCM token
        contact_user_res = await db.execute(
            select(User).where(User.phone == c.phone)
        )
        c_user = contact_user_res.scalar_one_or_none()
        if c_user and c_user.fcm_token:
            from app.services.notification_service import send_emergency_contact_fcm
            maps_url = f"https://maps.google.com/?q={body.location_lat},{body.location_lng}" if body.location_lat and body.location_lng else None
            try:
                fcm_sent = await send_emergency_contact_fcm(
                    fcm_token=c_user.fcm_token,
                    patient_name=user_name,
                    location_area=body.location_address or "Emergency Broadcast",
                    maps_url=maps_url,
                    scan_time=now_utc,
                    responder_name=user_name,
                )
                if fcm_sent:
                    fcm_count += 1
            except Exception:
                fcm_sent = False

        recipients_status.append(
            BroadcastRecipientStatus(
                contact_id=c.id,
                name=c.name,
                phone=c.phone,
                whatsapp_sent=wa_sent,
                fcm_sent=fcm_sent,
            )
        )

    await analytics_service.log_admin_event(
        event_name="admin_contact_broadcast",
        user_id=str(current_user.id),
        params={
            "broadcast_id": broadcast_id,
            "total_contacts": len(contacts),
            "whatsapp_sent_count": whatsapp_count,
            "fcm_sent_count": fcm_count,
        },
    )

    return GroupBroadcastResponse(
        broadcast_id=broadcast_id,
        group_id=body.group_id,
        group_name=group_name,
        total_contacts=len(contacts),
        whatsapp_sent_count=whatsapp_count,
        fcm_sent_count=fcm_count,
        recipients=recipients_status,
        sent_at=now_utc,
    )


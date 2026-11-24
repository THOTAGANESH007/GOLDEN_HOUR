"""
Unit tests for Contact Groups & Emergency Broadcast (Phase 2).
"""
import unittest
import uuid
from datetime import datetime, timezone

from app.models.contact_group import ContactGroup
from app.models.emergency_contact import EmergencyContact
from app.schemas.contact_group import (
    BroadcastRecipientStatus,
    ContactGroupCreate,
    ContactGroupResponse,
    ContactGroupUpdate,
    GroupBroadcastRequest,
    GroupBroadcastResponse,
)
from app.schemas.profile import EmergencyContactCreate


class TestContactGroups(unittest.TestCase):
    def test_contact_group_model_creation(self):
        user_id = uuid.uuid4()
        group_id = uuid.uuid4()
        group = ContactGroup(
            id=group_id,
            user_id=user_id,
            name="Family",
            description="Immediate family emergency contacts",
        )
        self.assertEqual(group.id, group_id)
        self.assertEqual(group.user_id, user_id)
        self.assertEqual(group.name, "Family")
        self.assertEqual(group.description, "Immediate family emergency contacts")
        self.assertIn("Family", repr(group))

    def test_emergency_contact_with_group_id(self):
        user_id = uuid.uuid4()
        group_id = uuid.uuid4()
        contact = EmergencyContact(
            user_id=user_id,
            group_id=group_id,
            name="Priya Sharma",
            relation="Spouse",
            phone="+919876543210",
        )
        self.assertEqual(contact.group_id, group_id)
        self.assertEqual(contact.name, "Priya Sharma")
        self.assertEqual(contact.relation, "Spouse")

    def test_contact_group_schemas(self):
        # Create schema
        create_schema = ContactGroupCreate(
            name="Workplace",
            description="Colleagues and office emergency team",
        )
        self.assertEqual(create_schema.name, "Workplace")
        self.assertEqual(create_schema.description, "Colleagues and office emergency team")

        # Update schema
        update_schema = ContactGroupUpdate(name="Office Emergency Team")
        self.assertEqual(update_schema.name, "Office Emergency Team")
        self.assertIsNone(update_schema.description)

        # Response schema
        gid = uuid.uuid4()
        uid = uuid.uuid4()
        now = datetime.now(timezone.utc)
        resp = ContactGroupResponse(
            id=gid,
            user_id=uid,
            name="Workplace",
            description="Colleagues",
            contact_count=0,
            contacts=[],
            created_at=now,
            updated_at=now,
        )
        self.assertEqual(resp.id, gid)
        self.assertEqual(resp.contact_count, 0)
        self.assertEqual(len(resp.contacts), 0)

    def test_group_broadcast_schemas(self):
        gid = uuid.uuid4()
        cid = uuid.uuid4()
        now = datetime.now(timezone.utc)

        req = GroupBroadcastRequest(
            group_id=gid,
            message="Need immediate assistance at office lobby.",
            location_lat=17.3850,
            location_lng=78.4867,
            location_address="Banjara Hills, Hyderabad",
        )
        self.assertEqual(req.group_id, gid)
        self.assertEqual(req.location_lat, 17.3850)

        recipient = BroadcastRecipientStatus(
            contact_id=cid,
            name="Rajesh Kumar",
            phone="+919876543210",
            whatsapp_sent=True,
            fcm_sent=True,
        )
        self.assertTrue(recipient.whatsapp_sent)
        self.assertTrue(recipient.fcm_sent)

        b_resp = GroupBroadcastResponse(
            broadcast_id="bcast_test123",
            group_id=gid,
            group_name="Family",
            total_contacts=1,
            whatsapp_sent_count=1,
            fcm_sent_count=1,
            recipients=[recipient],
            sent_at=now,
        )
        self.assertEqual(b_resp.total_contacts, 1)
        self.assertEqual(b_resp.whatsapp_sent_count, 1)
        self.assertEqual(b_resp.recipients[0].name, "Rajesh Kumar")

    def test_emergency_contact_create_with_group(self):
        gid = uuid.uuid4()
        c = EmergencyContactCreate(
            name="Sunita Rao",
            relation="Mother",
            phone="+919123456780",
            group_id=gid,
        )
        self.assertEqual(c.group_id, gid)
        self.assertEqual(c.phone, "+919123456780")


if __name__ == "__main__":
    unittest.main()


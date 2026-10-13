"""
Unit tests for core services, token management, UID generation, and schemas.
"""
import unittest
import uuid
from datetime import datetime, timezone
from pydantic import ValidationError

from app.schemas.auth import SendOTPRequest, VerifyOTPRequest
from app.schemas.profile import EmergencyContactCreate, ProfileUpdate
from app.services import auth_service
from app.services.qr_service import generate_uid, _parse_device_type
from app.services.notification_service import _ist_time


class TestAuthService(unittest.TestCase):
    def test_access_and_refresh_token_lifecycle(self):
        user_id = uuid.uuid4()
        access_token = auth_service.create_access_token(user_id)
        refresh_token = auth_service.create_refresh_token(user_id)

        self.assertIsInstance(access_token, str)
        self.assertIsInstance(refresh_token, str)

        access_payload = auth_service.decode_token(access_token)
        self.assertEqual(access_payload["sub"], str(user_id))
        self.assertEqual(access_payload["type"], "access")

        refresh_payload = auth_service.decode_token(refresh_token)
        self.assertEqual(refresh_payload["sub"], str(user_id))
        self.assertEqual(refresh_payload["type"], "refresh")
        self.assertIn("jti", refresh_payload)

    def test_token_hashing(self):
        token = "sample-secret-refresh-token"
        h1 = auth_service.hash_token(token)
        h2 = auth_service.hash_token(token)
        self.assertEqual(h1, h2)
        self.assertEqual(len(h1), 64)  # SHA-256 hex length


class TestQRService(unittest.TestCase):
    def test_generate_uid_format(self):
        uid = generate_uid(8)
        self.assertEqual(len(uid), 8)
        self.assertTrue(uid.isalnum())
        self.assertTrue(uid.isupper())

    def test_parse_device_type(self):
        self.assertEqual(
            _parse_device_type("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)"),
            "mobile",
        )
        self.assertEqual(
            _parse_device_type("Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X)"),
            "tablet",
        )
        self.assertEqual(
            _parse_device_type("Mozilla/5.0 (Windows NT 10.0; Win64; x64)"),
            "desktop",
        )
        self.assertEqual(_parse_device_type(None), "unknown")


class TestNotificationService(unittest.TestCase):
    def test_ist_time_formatting(self):
        utc_dt = datetime(2026, 10, 13, 12, 0, 0, tzinfo=timezone.utc)
        ist_str = _ist_time(utc_dt)
        # 12:00 UTC + 5:30 = 17:30 IST
        self.assertEqual(ist_str, "17:30 IST")


class TestSchemas(unittest.TestCase):
    def test_phone_validation_e164(self):
        # Valid E.164
        req = SendOTPRequest(phone="+919876543210")
        self.assertEqual(req.phone, "+919876543210")

        # Invalid phone without country code or incorrect format
        with self.assertRaises(ValidationError):
            SendOTPRequest(phone="9876543210")

        with self.assertRaises(ValidationError):
            SendOTPRequest(phone="invalid")

    def test_emergency_contact_create(self):
        contact = EmergencyContactCreate(
            name="John Doe",
            relation="Brother",
            phone="+919876543210",
            whatsapp_enabled=True,
            notify_on_scan=True,
        )
        self.assertEqual(contact.name, "John Doe")
        self.assertEqual(contact.relation, "Brother")

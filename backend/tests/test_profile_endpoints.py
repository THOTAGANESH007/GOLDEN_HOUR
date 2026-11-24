"""
Integration & unit tests for Profile endpoints and DPDPA compliance:
- GET /api/v1/profile/me
- PUT /api/v1/profile/me
- GET /api/v1/profile/completion
- PATCH /api/v1/profile/me/privacy
- PATCH /api/v1/profile/me/status
- DELETE /api/v1/auth/delete-account (DPDPA Right to Erasure)
"""
import unittest
import uuid
from datetime import date, datetime, timezone
from unittest.mock import AsyncMock, MagicMock
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.profile import Profile
from app.models.user import User


class TestProfileEndpoints(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.transport = ASGITransport(app=app)
        self.user_id = uuid.uuid4()
        self.profile_id = uuid.uuid4()
        self.mock_user = User(
            id=self.user_id,
            phone="+919876543210",
        )

        now = datetime.now(timezone.utc)
        self.mock_profile = Profile(
            id=self.profile_id,
            user_id=self.user_id,
            qr_uid="GH-TEST-1234",
            qr_is_active=True,
            full_name="Arjun Kapoor",
            date_of_birth=date(1995, 8, 20),
            gender="Male",
            blood_group="O+",
            allergies=["Penicillin"],
            chronic_conditions=["Asthma"],
            medications=[],
            past_surgeries=[],
            implants=[],
            is_organ_donor=True,
            doctor_name="Dr. Mehta",
            doctor_phone="+919811122233",
            show_name=True,
            show_dob=True,
            show_photo=False,
            wizard_completed=True,
            created_at=now,
            updated_at=now,
        )

        self.mock_db = AsyncMock()

        # Setup mock db query responses
        async def mock_execute(query, *args, **kwargs):
            res = MagicMock()
            query_str = str(query)
            if "count" in query_str.lower():
                res.scalar_one.return_value = 1
                res.scalar_one_or_none.return_value = 1
            else:
                res.scalar_one_or_none.return_value = self.mock_profile
                res.scalar_one.return_value = self.mock_profile
                mock_scalars = MagicMock()
                mock_scalars.all.return_value = [self.mock_profile]
                res.scalars.return_value = mock_scalars
            return res

        self.mock_db.execute.side_effect = mock_execute
        self.mock_db.commit = AsyncMock()
        self.mock_db.refresh = AsyncMock()
        self.mock_db.delete = AsyncMock()
        self.mock_db.add = MagicMock()

        async def override_get_db():
            yield self.mock_db

        async def override_get_current_user():
            return self.mock_user

        app.dependency_overrides[get_db] = override_get_db
        app.dependency_overrides[get_current_user] = override_get_current_user

    async def asyncTearDown(self):
        app.dependency_overrides.clear()
        from app.database import engine
        await engine.dispose()

    async def test_get_my_profile(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.get("/api/v1/profile/me")
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertEqual(data["full_name"], "Arjun Kapoor")
            self.assertEqual(data["blood_group"], "O+")
            self.assertEqual(data["qr_uid"], "GH-TEST-1234")
            self.assertTrue(data["qr_is_active"])

    async def test_update_profile_info(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            payload = {
                "full_name": "Arjun K. Verma",
                "blood_group": "A+",
                "is_organ_donor": True,
                "chronic_conditions": ["None"],
            }
            response = await client.put("/api/v1/profile/me", json=payload)
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertEqual(data["full_name"], "Arjun K. Verma")
            self.assertEqual(data["blood_group"], "A+")

    async def test_get_profile_completion_score(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.get("/api/v1/profile/completion")
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertIn("score", data)
            self.assertIn("missing", data)
            self.assertGreaterEqual(data["score"], 0)
            self.assertLessEqual(data["score"], 100)

    async def test_update_privacy_controls(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            payload = {
                "show_name": False,
                "show_dob": False,
                "show_photo": True,
            }
            response = await client.patch("/api/v1/profile/me/privacy", json=payload)
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertFalse(data["show_name"])
            self.assertFalse(data["show_dob"])
            self.assertTrue(data["show_photo"])

    async def test_update_qr_status_deactivate(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.patch("/api/v1/profile/me/status", json={"qr_is_active": False})
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertFalse(data["qr_is_active"])

    async def test_dpdpa_delete_account_right_to_erasure(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.delete("/api/v1/auth/delete-account")
            self.assertEqual(response.status_code, 204)
            self.mock_db.delete.assert_called_once_with(self.mock_user)

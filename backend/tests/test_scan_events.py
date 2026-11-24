"""
Integration tests for Scan Events endpoints:
- GET /api/v1/scan-events (Paginated scan history)
- GET /api/v1/scan-events/{event_id}
- PATCH /api/v1/scan-events/{event_id}/false-alarm
"""
import unittest
import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.scan_event import ScanEvent
from app.models.user import User


class TestScanEvents(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.transport = ASGITransport(app=app)
        self.user_id = uuid.uuid4()
        self.event_id = uuid.uuid4()

        self.mock_user = User(
            id=self.user_id,
            phone="+919876543210",
        )

        self.mock_event = ScanEvent(
            id=self.event_id,
            user_id=self.user_id,
            qr_uid="GH-TEST-1234",
            scanned_at=datetime.now(timezone.utc),
            latitude=28.6139,
            longitude=77.2090,
            location_area="New Delhi, Delhi",
            google_maps_url="https://maps.google.com/?q=28.6139,77.2090",
            responder_name="Paramedic Sharma",
            responder_hospital="AIIMS New Delhi",
            is_false_alarm=False,
            device_type="mobile",
            sms_sent=True,
            whatsapp_sent=False,
            fcm_sent=True,
            email_sent=False,
            notification_suppressed=False,
        )

        self.mock_db = AsyncMock()

        async def mock_execute(query, *args, **kwargs):
            res = MagicMock()
            query_str = str(query)
            if "count" in query_str.lower():
                res.scalar_one.return_value = 1
                res.scalar_one_or_none.return_value = 1
            else:
                res.scalar_one_or_none.return_value = self.mock_event
                res.scalar_one.return_value = self.mock_event
                mock_scalars = MagicMock()
                mock_scalars.all.return_value = [self.mock_event]
                res.scalars.return_value = mock_scalars
            return res

        self.mock_db.execute.side_effect = mock_execute
        self.mock_db.commit = AsyncMock()
        self.mock_db.refresh = AsyncMock()
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

    async def test_list_scan_events_paginated(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.get("/api/v1/scan-events?page=1&page_size=10")
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertIn("items", data)
            self.assertIn("total", data)
            self.assertEqual(data["total"], 1)
            self.assertEqual(len(data["items"]), 1)
            self.assertEqual(data["items"][0]["location_area"], "New Delhi, Delhi")
            self.assertEqual(data["items"][0]["qr_uid"], "GH-TEST-1234")

    async def test_get_scan_event_detail(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.get(f"/api/v1/scan-events/{self.event_id}")
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertEqual(data["id"], str(self.event_id))
            self.assertEqual(data["responder_name"], "Paramedic Sharma")
            self.assertEqual(data["location_area"], "New Delhi, Delhi")

    async def test_toggle_false_alarm(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.patch(
                f"/api/v1/scan-events/{self.event_id}/false-alarm",
                json={"is_false_alarm": True},
            )
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertTrue(data["is_false_alarm"])

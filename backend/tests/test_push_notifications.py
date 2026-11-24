import unittest
from app.schemas.notification import (
    CATEGORY_APP_UPDATE,
    CATEGORY_EMERGENCY_SOS,
    CATEGORY_RADAR_ALERT,
    CATEGORY_SAFETY_TIP,
    VALID_CATEGORIES,
    PushNotificationRequest,
    PushNotificationResponse,
)
from app.services.notification_service import send_enhanced_push


class TestPushNotificationSchemas(unittest.TestCase):
    def test_valid_push_request(self):
        req = PushNotificationRequest(
            title="Emergency SOS Alert",
            body="Your safety profile was scanned nearby",
            category=CATEGORY_EMERGENCY_SOS,
            data={"scan_id": "12345", "location": "Connaught Place"},
            is_data_only=False,
        )
        self.assertEqual(req.title, "Emergency SOS Alert")
        self.assertEqual(req.category, "emergency_sos")
        self.assertEqual(req.data["scan_id"], "12345")
        self.assertFalse(req.is_data_only)

    def test_data_only_push_request(self):
        req = PushNotificationRequest(
            title="Background Radar Ping",
            body="Sync coordinates",
            category=CATEGORY_RADAR_ALERT,
            is_data_only=True,
        )
        self.assertTrue(req.is_data_only)
        self.assertEqual(req.category, "radar_alert")

    def test_all_categories_recognized(self):
        self.assertIn(CATEGORY_EMERGENCY_SOS, VALID_CATEGORIES)
        self.assertIn(CATEGORY_SAFETY_TIP, VALID_CATEGORIES)
        self.assertIn(CATEGORY_APP_UPDATE, VALID_CATEGORIES)
        self.assertIn(CATEGORY_RADAR_ALERT, VALID_CATEGORIES)

    def test_push_response_serialization(self):
        resp = PushNotificationResponse(
            status="success",
            message="Push delivered to 2 devices",
            success_count=2,
            failure_count=0,
            category=CATEGORY_SAFETY_TIP,
            is_data_only=False,
            analytics_event="notification_sent",
            dispatched_at="2026-11-24T12:00:00Z",
        )
        self.assertEqual(resp.analytics_event, "notification_sent")
        self.assertEqual(resp.success_count, 2)


class TestPushNotificationService(unittest.IsolatedAsyncioTestCase):
    async def test_send_enhanced_push_empty_tokens(self):
        success, failure = await send_enhanced_push(
            fcm_tokens=[],
            title="Test",
            body="Test Body",
        )
        self.assertEqual(success, 0)
        self.assertEqual(failure, 0)

    async def test_send_enhanced_push_with_tokens(self):
        # In test mode without live Google credentials, returns simulated success
        tokens = ["token_device_alpha", "token_device_beta"]
        success, failure = await send_enhanced_push(
            fcm_tokens=tokens,
            title="🚨 Emergency SOS",
            body="Immediate assistance needed",
            category=CATEGORY_EMERGENCY_SOS,
            custom_data={"urgency": "critical"},
            is_data_only=False,
        )
        self.assertEqual(success + failure, 2)


if __name__ == "__main__":
    unittest.main()


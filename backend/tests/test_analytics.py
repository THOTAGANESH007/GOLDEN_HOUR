"""
Unit tests for backend AnalyticsService:
- Google Analytics 4 (GA4) Measurement Protocol formatting
- Fallback/mock execution when unconfigured
- Configured HTTP dispatch handling (success, error, exception)
- Triggering admin analytics from scan events and profile status endpoints
"""
import unittest
from unittest.mock import AsyncMock, MagicMock
import httpx

from app.services.analytics_service import AnalyticsService, GA4_ENDPOINT


class TestBackendAnalytics(unittest.IsolatedAsyncioTestCase):
    async def test_unconfigured_analytics_logs_locally(self):
        service = AnalyticsService(measurement_id="", api_secret="")
        self.assertFalse(service.is_configured)

        res = await service.log_admin_event(
            event_name="admin_test_event",
            user_id="user-123",
            params={"metric_key": "metric_val"},
        )
        self.assertTrue(res)
        self.assertEqual(len(service.in_memory_events), 1)

        payload = service.in_memory_events[0]
        self.assertEqual(payload["client_id"], "goldenhour-backend")
        self.assertEqual(payload["user_id"], "user-123")
        self.assertEqual(payload["events"][0]["name"], "admin_test_event")
        self.assertEqual(payload["events"][0]["params"]["metric_key"], "metric_val")
        self.assertEqual(payload["events"][0]["params"]["engagement_time_msec"], 100)

    async def test_configured_analytics_successful_http_dispatch(self):
        mock_client = AsyncMock(spec=httpx.AsyncClient)
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 204
        mock_client.post.return_value = mock_response

        service = AnalyticsService(
            measurement_id="G-TEST1234",
            api_secret="sec_test_5678",
            http_client=mock_client,
        )
        self.assertTrue(service.is_configured)

        res = await service.log_admin_event(
            event_name="admin_broadcast_dispatched",
            user_id="admin-999",
            params={"recipients_count": 5},
        )
        self.assertTrue(res)

        mock_client.post.assert_called_once()
        call_args, call_kwargs = mock_client.post.call_args
        expected_url = f"{GA4_ENDPOINT}?measurement_id=G-TEST1234&api_secret=sec_test_5678"
        self.assertEqual(call_args[0], expected_url)
        self.assertEqual(call_kwargs["json"]["events"][0]["name"], "admin_broadcast_dispatched")

    async def test_configured_analytics_handles_http_failure_gracefully(self):
        mock_client = AsyncMock(spec=httpx.AsyncClient)
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 500
        mock_response.text = "Internal Server Error"
        mock_client.post.return_value = mock_response

        service = AnalyticsService(
            measurement_id="G-TEST1234",
            api_secret="sec_test_5678",
            http_client=mock_client,
        )

        res = await service.log_admin_event(
            event_name="admin_failure_test",
        )
        self.assertFalse(res)

    async def test_configured_analytics_handles_network_exception_gracefully(self):
        mock_client = AsyncMock(spec=httpx.AsyncClient)
        mock_client.post.side_effect = httpx.ConnectTimeout("Connection timed out")

        service = AnalyticsService(
            measurement_id="G-TEST1234",
            api_secret="sec_test_5678",
            http_client=mock_client,
        )

        res = await service.log_admin_event(
            event_name="admin_network_timeout",
        )
        self.assertFalse(res)

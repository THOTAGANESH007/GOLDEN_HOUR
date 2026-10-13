"""
Integration tests for FastAPI endpoints: Auth, QR public scan, Documents validation.
"""
import unittest
from unittest.mock import patch, AsyncMock
from httpx import ASGITransport, AsyncClient

from app.main import app


class TestAPIEndpoints(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.transport = ASGITransport(app=app)

    async def test_send_otp_validation_failure(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            # Phone without '+' or country code should return 422 Unprocessable Entity
            response = await client.post("/api/v1/auth/send-otp", json={"phone": "12345"})
            self.assertEqual(response.status_code, 422)

    async def test_send_otp_success_mocked(self):
        with patch("app.services.auth_service.send_otp", new_callable=AsyncMock) as mock_send:
            mock_send.return_value = {"status": "success"}
            async with AsyncClient(transport=self.transport, base_url="http://test") as client:
                response = await client.post(
                    "/api/v1/auth/send-otp",
                    json={"phone": "+919876543210", "consent_given": True},
                )
                self.assertEqual(response.status_code, 200)
                data = response.json()
                self.assertEqual(data.get("message"), "OTP sent successfully")

    async def test_verify_otp_invalid_error(self):
        with patch("app.services.auth_service.verify_otp", new_callable=AsyncMock) as mock_verify:
            mock_verify.side_effect = Exception("Invalid OTP")
            async with AsyncClient(transport=self.transport, base_url="http://test") as client:
                response = await client.post(
                    "/api/v1/auth/verify-otp",
                    json={"phone": "+919876543210", "otp": "000000"},
                )
                self.assertEqual(response.status_code, 401)
                self.assertIn("Invalid OTP", response.json()["detail"])

    async def test_protected_route_requires_auth(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            # Accessing /api/v1/profile/me without Authorization header should return 401 or 403
            response = await client.get("/api/v1/profile/me")
            self.assertIn(response.status_code, [401, 403])

    async def test_documents_requires_auth(self):
        async with AsyncClient(transport=self.transport, base_url="http://test") as client:
            response = await client.get("/api/v1/documents")
            self.assertIn(response.status_code, [401, 403])

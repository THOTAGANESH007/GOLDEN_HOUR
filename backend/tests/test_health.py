"""
Tests for health check endpoint using httpx ASGI transport.
"""
import unittest
from httpx import ASGITransport, AsyncClient

from app.main import app


class TestHealthEndpoint(unittest.IsolatedAsyncioTestCase):
    async def test_health_check_returns_200(self):
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/health")
            self.assertEqual(response.status_code, 200)
            data = response.json()
            self.assertEqual(data.get("status"), "healthy")
            self.assertEqual(data.get("service"), "Golden Hour API")

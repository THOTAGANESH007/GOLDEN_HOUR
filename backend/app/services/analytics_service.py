"""
Google Analytics 4 (GA4) Measurement Protocol service for backend admin & audit events.
Reference: https://developers.google.com/analytics/devguides/collection/protocol/ga4
"""
import logging
from typing import Any
import httpx

from app.config import get_settings

logger = logging.getLogger("app.analytics")

GA4_ENDPOINT = "https://www.google-analytics.com/mp/collect"


class AnalyticsService:
    def __init__(
        self,
        measurement_id: str | None = None,
        api_secret: str | None = None,
        http_client: httpx.AsyncClient | None = None,
    ):
        settings = get_settings()
        self.measurement_id = (
            measurement_id if measurement_id is not None else settings.ga_measurement_id
        )
        self.api_secret = api_secret if api_secret is not None else settings.ga_api_secret
        self._http_client = http_client
        self.in_memory_events: list[dict[str, Any]] = []

    @property
    def is_configured(self) -> bool:
        return bool(self.measurement_id and self.api_secret)

    def clear_in_memory_events(self) -> None:
        self.in_memory_events.clear()

    async def log_admin_event(
        self,
        event_name: str,
        client_id: str = "goldenhour-backend",
        user_id: str | None = None,
        params: dict[str, Any] | None = None,
    ) -> bool:
        """
        Send an admin action or audit event to Google Analytics 4 via Measurement Protocol.
        Returns True if recorded or sent successfully.
        """
        payload_params = params.copy() if params else {}
        payload_params.setdefault("engagement_time_msec", 100)

        event_payload = {
            "name": event_name,
            "params": payload_params,
        }

        request_body: dict[str, Any] = {
            "client_id": client_id,
            "events": [event_payload],
        }
        if user_id:
            request_body["user_id"] = str(user_id)

        self.in_memory_events.append(request_body)

        if not self.is_configured:
            logger.info(
                f"[Analytics GA4 (unconfigured)] Event: {event_name}, Params: {payload_params}"
            )
            return True

        url = f"{GA4_ENDPOINT}?measurement_id={self.measurement_id}&api_secret={self.api_secret}"
        try:
            if self._http_client:
                response = await self._http_client.post(url, json=request_body)
            else:
                async with httpx.AsyncClient(timeout=5.0) as client:
                    response = await client.post(url, json=request_body)

            if response.status_code in (200, 204):
                logger.debug(f"[Analytics GA4] Sent {event_name} successfully")
                return True
            else:
                logger.warning(
                    f"[Analytics GA4] Failed sending {event_name}: {response.status_code} - {response.text}"
                )
                return False
        except Exception as exc:
            logger.warning(f"[Analytics GA4] Network error sending {event_name}: {exc}")
            return False


analytics_service = AnalyticsService()

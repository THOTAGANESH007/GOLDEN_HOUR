import json
import unittest
from datetime import datetime, timezone
from fastapi.testclient import TestClient

from app.main import app
from app.schemas.location import LocationUpdate, StopSharingRequest
from app.services.location_service import (
    calculate_haversine_distance_meters,
    check_geofence,
    get_nearby_peers,
    remove_location,
    store_location,
    _in_memory_locations,
)


class TestLocationService(unittest.TestCase):
    def setUp(self):
        _in_memory_locations.clear()

    def test_haversine_distance_calculation(self):
        # Coordinates for Bangalore center and Indiranagar (~5.5km)
        lat1, lon1 = 12.9716, 77.5946
        lat2, lon2 = 12.9784, 77.6408
        dist = calculate_haversine_distance_meters(lat1, lon1, lat2, lon2)
        # Should be between 4,500m and 5,500m
        self.assertGreater(dist, 4500)
        self.assertLess(dist, 5500)

        # Same location should be 0 meters
        self.assertEqual(calculate_haversine_distance_meters(lat1, lon1, lat1, lon1), 0.0)

    def test_geofence_evaluation(self):
        center_lat, center_lon = 12.9716, 77.5946
        radius = 500.0  # 500 meters

        # Inside safe zone: 100 meters away
        inside_lat = 12.9720
        status_inside = check_geofence(
            lat=inside_lat,
            lon=center_lon,
            center_lat=center_lat,
            center_lon=center_lon,
            radius_meters=radius,
        )
        self.assertTrue(status_inside.in_safe_zone)
        self.assertFalse(status_inside.alert_triggered)
        self.assertLess(status_inside.distance_from_center_meters, radius)

        # Outside safe zone: 2km away
        outside_lat = 12.9900
        status_outside = check_geofence(
            lat=outside_lat,
            lon=center_lon,
            center_lat=center_lat,
            center_lon=center_lon,
            radius_meters=radius,
        )
        self.assertFalse(status_outside.in_safe_zone)
        self.assertTrue(status_outside.alert_triggered)
        self.assertGreater(status_outside.distance_from_center_meters, radius)

    async def _async_location_flow(self):
        # User 1 update
        u1 = LocationUpdate(
            user_id="user_1",
            display_name="User One",
            latitude=12.9716,
            longitude=77.5946,
            timestamp=datetime.now(timezone.utc).isoformat(),
            is_sharing=True,
            safe_zone_radius_meters=500.0,
        )
        await store_location(u1)

        # User 2 update (nearby ~500m)
        u2 = LocationUpdate(
            user_id="user_2",
            display_name="User Two",
            latitude=12.9740,
            longitude=77.5960,
            timestamp=datetime.now(timezone.utc).isoformat(),
            is_sharing=True,
        )
        await store_location(u2)

        # User 3 update (far away ~50km)
        u3 = LocationUpdate(
            user_id="user_3",
            display_name="User Three",
            latitude=13.3400,
            longitude=77.1000,
            timestamp=datetime.now(timezone.utc).isoformat(),
            is_sharing=True,
        )
        await store_location(u3)

        # User 1 queries peers within 10km
        peers = await get_nearby_peers("user_1", 12.9716, 77.5946, radius_km=10.0)
        peer_ids = [p.user_id for p in peers]
        self.assertIn("user_2", peer_ids)
        self.assertNotIn("user_1", peer_ids)  # Excludes self
        self.assertNotIn("user_3", peer_ids)  # User 3 is 50km away

        # Stop sharing for user 2
        await remove_location("user_2")
        peers_after_stop = await get_nearby_peers("user_1", 12.9716, 77.5946, radius_km=10.0)
        self.assertEqual(len(peers_after_stop), 0)

    def test_location_storage_and_peers(self):
        import asyncio
        asyncio.run(self._async_location_flow())


class TestLocationEndpoints(unittest.TestCase):
    def setUp(self):
        _in_memory_locations.clear()
        self.client = TestClient(app)

    def test_update_and_get_peers_rest(self):
        # Publish User A
        res_a = self.client.post(
            "/api/v1/location/update",
            json={
                "user_id": "test_user_a",
                "display_name": "Alice Responder",
                "latitude": 17.3850,
                "longitude": 78.4867,
                "timestamp": "2026-11-24T10:00:00Z",
                "is_sharing": True,
                "safe_zone_radius_meters": 300.0,
                "safe_zone_center_lat": 17.3850,
                "safe_zone_center_lon": 78.4867,
            },
        )
        self.assertEqual(res_a.status_code, 200)
        data_a = res_a.json()
        self.assertEqual(data_a["status"], "success")
        self.assertTrue(data_a["geofence"]["in_safe_zone"])

        # Publish User B nearby (~200m away)
        res_b = self.client.post(
            "/api/v1/location/update",
            json={
                "user_id": "test_user_b",
                "display_name": "Bob Helper",
                "latitude": 17.3860,
                "longitude": 78.4875,
                "timestamp": "2026-11-24T10:00:00Z",
                "is_sharing": True,
            },
        )
        self.assertEqual(res_b.status_code, 200)

        # Query peers for User A
        res_peers = self.client.get(
            "/api/v1/location/peers",
            params={"user_id": "test_user_a", "lat": 17.3850, "lon": 78.4867, "radius_km": 5.0},
        )
        self.assertEqual(res_peers.status_code, 200)
        peers_data = res_peers.json()
        self.assertEqual(peers_data["count"], 1)
        self.assertEqual(peers_data["peers"][0]["user_id"], "test_user_b")
        self.assertEqual(peers_data["peers"][0]["display_name"], "Bob Helper")

        # Stop sharing
        res_stop = self.client.post(
            "/api/v1/location/stop",
            json={"user_id": "test_user_b"},
        )
        self.assertEqual(res_stop.status_code, 200)

        # Query peers again -> count 0
        res_peers_empty = self.client.get(
            "/api/v1/location/peers",
            params={"user_id": "test_user_a", "lat": 17.3850, "lon": 78.4867, "radius_km": 5.0},
        )
        self.assertEqual(res_peers_empty.json()["count"], 0)

    def test_geofence_check_endpoint(self):
        res = self.client.post(
            "/api/v1/location/geofence/check",
            params={
                "lat": 12.9716,
                "lon": 77.5946,
                "center_lat": 12.9716,
                "center_lon": 77.5946,
                "radius_meters": 200.0,
            },
        )
        self.assertEqual(res.status_code, 200)
        self.assertTrue(res.json()["in_safe_zone"])
        self.assertFalse(res.json()["alert_triggered"])

    def test_websocket_location_streaming(self):
        with self.client.websocket_connect("/ws/location") as websocket:
            # 1. Ping
            websocket.send_text(json.dumps({"type": "ping"}))
            resp = json.loads(websocket.receive_text())
            self.assertEqual(resp["type"], "pong")

            # 2. Location update
            update_payload = {
                "type": "update",
                "data": {
                    "user_id": "ws_user_1",
                    "display_name": "WS Responder",
                    "latitude": 28.6139,
                    "longitude": 77.2090,
                    "timestamp": "2026-11-24T12:00:00Z",
                    "is_sharing": True,
                    "safe_zone_radius_meters": 400.0,
                    "safe_zone_center_lat": 28.6139,
                    "safe_zone_center_lon": 77.2090,
                },
            }
            websocket.send_text(json.dumps(update_payload))
            ack_resp = json.loads(websocket.receive_text())
            self.assertEqual(ack_resp["type"], "ack")
            self.assertEqual(ack_resp["status"], "stored")
            self.assertTrue(ack_resp["geofence"]["in_safe_zone"])

            # 3. Stop
            websocket.send_text(json.dumps({"type": "stop", "user_id": "ws_user_1"}))
            stop_resp = json.loads(websocket.receive_text())
            self.assertEqual(stop_resp["type"], "stopped")


if __name__ == "__main__":
    unittest.main()

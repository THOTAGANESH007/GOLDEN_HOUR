import json
import math
from datetime import datetime, timezone
from typing import Optional

from app.config import get_settings
from app.schemas.location import GeofenceStatus, LocationUpdate, PeerLocation

settings = get_settings()

# In-memory location cache fallback if Redis is unavailable
_in_memory_locations: dict[str, dict] = {}
LOCATION_TTL_SECONDS = 300  # 5 minutes auto-expiry


async def _get_redis_client():
    try:
        import redis.asyncio as aioredis
        client = aioredis.from_url(
            settings.redis_url,
            decode_responses=True,
            socket_timeout=3,
            socket_connect_timeout=3,
        )
        await client.ping()
        return client
    except Exception:
        return None


def calculate_haversine_distance_meters(
    lat1: float, lon1: float, lat2: float, lon2: float
) -> float:
    """
    Computes great-circle distance between two GPS coordinates in meters.
    """
    R = 6371000.0  # Earth radius in meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_phi / 2.0) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return round(R * c, 2)


async def store_location(update: LocationUpdate) -> dict:
    """
    Store or update a user's location in Redis with TTL and in-memory cache.
    """
    now = datetime.now(timezone.utc)
    data = {
        "user_id": update.user_id,
        "display_name": update.display_name or "Emergency Peer",
        "latitude": update.latitude,
        "longitude": update.longitude,
        "accuracy": update.accuracy,
        "heading": update.heading,
        "speed": update.speed,
        "timestamp": update.timestamp or now.isoformat(),
        "is_sharing": update.is_sharing,
        "safe_zone_radius_meters": update.safe_zone_radius_meters or 500.0,
        "safe_zone_center_lat": update.safe_zone_center_lat,
        "safe_zone_center_lon": update.safe_zone_center_lon,
        "_stored_at": now.timestamp(),
    }

    # 1. Update in-memory fallback
    if update.is_sharing:
        _in_memory_locations[update.user_id] = data
    else:
        _in_memory_locations.pop(update.user_id, None)

    # 2. Update Redis
    redis_client = await _get_redis_client()
    if redis_client:
        try:
            key = f"loc:{update.user_id}"
            if update.is_sharing:
                await redis_client.set(key, json.dumps(data), ex=LOCATION_TTL_SECONDS)
                await redis_client.sadd("active_location_users", update.user_id)
            else:
                await redis_client.delete(key)
                await redis_client.srem("active_location_users", update.user_id)
        except Exception:
            pass
        finally:
            await redis_client.aclose()

    return data


async def remove_location(user_id: str) -> None:
    """
    Remove user location on stop sharing or disconnect.
    """
    _in_memory_locations.pop(user_id, None)
    redis_client = await _get_redis_client()
    if redis_client:
        try:
            await redis_client.delete(f"loc:{user_id}")
            await redis_client.srem("active_location_users", user_id)
        except Exception:
            pass
        finally:
            await redis_client.aclose()


async def get_nearby_peers(
    user_id: str, lat: float, lon: float, radius_km: float = 10.0
) -> list[PeerLocation]:
    """
    Returns active peer locations within radius_km (excluding user_id).
    """
    max_distance_meters = radius_km * 1000.0
    now = datetime.now(timezone.utc).timestamp()
    all_data: list[dict] = []

    # 1. Try Redis first
    redis_client = await _get_redis_client()
    if redis_client:
        try:
            user_ids = await redis_client.smembers("active_location_users")
            for uid in user_ids:
                if uid == user_id:
                    continue
                raw = await redis_client.get(f"loc:{uid}")
                if raw:
                    all_data.append(json.loads(raw))
                else:
                    await redis_client.srem("active_location_users", uid)
        except Exception:
            all_data = []
        finally:
            await redis_client.aclose()

    # 2. Fallback to in-memory if Redis returned empty or failed
    if not all_data:
        expired = []
        for uid, d in _in_memory_locations.items():
            if now - d.get("_stored_at", 0) > LOCATION_TTL_SECONDS:
                expired.append(uid)
            elif uid != user_id and d.get("is_sharing", True):
                all_data.append(d)
        for e in expired:
            _in_memory_locations.pop(e, None)

    peers: list[PeerLocation] = []
    for d in all_data:
        dist = calculate_haversine_distance_meters(
            lat, lon, d["latitude"], d["longitude"]
        )
        if dist <= max_distance_meters:
            peers.append(
                PeerLocation(
                    user_id=d["user_id"],
                    display_name=d.get("display_name", "Emergency Peer"),
                    latitude=d["latitude"],
                    longitude=d["longitude"],
                    distance_meters=dist,
                    updated_at=d.get("timestamp", datetime.now(timezone.utc).isoformat()),
                    is_sharing=d.get("is_sharing", True),
                    status="active",
                )
            )

    peers.sort(key=lambda p: p.distance_meters if p.distance_meters is not None else float("inf"))
    return peers


def check_geofence(
    lat: float,
    lon: float,
    center_lat: Optional[float],
    center_lon: Optional[float],
    radius_meters: Optional[float] = 500.0,
) -> GeofenceStatus:
    """
    Evaluates whether the given coordinate is within the designated safe zone.
    """
    if center_lat is None or center_lon is None:
        return GeofenceStatus(
            in_safe_zone=True,
            distance_from_center_meters=0.0,
            safe_zone_radius_meters=radius_meters or 500.0,
            alert_triggered=False,
            message="No geofence center established; position within safe boundaries.",
        )

    radius = radius_meters if radius_meters and radius_meters > 0 else 500.0
    dist = calculate_haversine_distance_meters(lat, lon, center_lat, center_lon)
    in_zone = dist <= radius
    alert = not in_zone

    msg = (
        f"Within emergency safe zone ({round(dist, 1)}m / {radius}m)."
        if in_zone
        else f"Safe zone perimeter breached! Currently {round(dist, 1)}m from center (limit {radius}m)."
    )

    return GeofenceStatus(
        in_safe_zone=in_zone,
        distance_from_center_meters=dist,
        safe_zone_radius_meters=radius,
        alert_triggered=alert,
        message=msg,
    )

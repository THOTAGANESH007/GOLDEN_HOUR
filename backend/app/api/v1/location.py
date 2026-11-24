import json
import logging
from typing import Optional

from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

from app.schemas.location import (
    GeofenceStatus,
    LocationUpdate,
    PeersResponse,
    StopSharingRequest,
)
from app.services.location_service import (
    check_geofence,
    get_nearby_peers,
    remove_location,
    store_location,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/location", tags=["Real-Time Location & Geofencing"])


@router.get("/peers", response_model=PeersResponse)
async def fetch_nearby_peers(
    user_id: str = Query(..., description="Querying user ID"),
    lat: float = Query(..., ge=-90.0, le=90.0, description="User GPS latitude"),
    lon: float = Query(..., ge=-180.0, le=180.0, description="User GPS longitude"),
    radius_km: float = Query(10.0, ge=0.1, le=100.0, description="Search radius in kilometers"),
):
    """
    Fetch active emergency peers sharing location within radius_km.
    """
    peers = await get_nearby_peers(user_id=user_id, lat=lat, lon=lon, radius_km=radius_km)
    return PeersResponse(
        peers=peers,
        count=len(peers),
        user_latitude=lat,
        user_longitude=lon,
        search_radius_km=radius_km,
    )


@router.post("/update")
async def update_location(body: LocationUpdate):
    """
    REST endpoint to publish GPS coordinates and evaluate geofence status.
    """
    stored = await store_location(body)
    geofence = check_geofence(
        lat=body.latitude,
        lon=body.longitude,
        center_lat=body.safe_zone_center_lat,
        center_lon=body.safe_zone_center_lon,
        radius_meters=body.safe_zone_radius_meters,
    )
    return {
        "status": "success",
        "message": "Location updated successfully",
        "data": stored,
        "geofence": geofence.model_dump(),
    }


@router.post("/stop")
async def stop_location_sharing(body: StopSharingRequest):
    """
    Stop broadcasting location and remove from active peer radar.
    """
    await remove_location(body.user_id)
    return {"status": "success", "message": "Location sharing stopped"}


@router.post("/geofence/check", response_model=GeofenceStatus)
async def verify_geofence(
    lat: float = Query(..., ge=-90.0, le=90.0),
    lon: float = Query(..., ge=-180.0, le=180.0),
    center_lat: Optional[float] = Query(None),
    center_lon: Optional[float] = Query(None),
    radius_meters: Optional[float] = Query(500.0, ge=10.0, le=50000.0),
):
    """
    Verify whether coordinates are inside the defined safe-zone radius.
    """
    return check_geofence(
        lat=lat,
        lon=lon,
        center_lat=center_lat,
        center_lon=center_lon,
        radius_meters=radius_meters,
    )


async def handle_location_websocket(websocket: WebSocket):
    """
    FastAPI WebSocket endpoint handler for /ws/location.
    Streams location updates, evaluates safe-zone geofencing, and broadcasts nearby peers.
    """
    await websocket.accept()
    connected_user_id: Optional[str] = None
    try:
        while True:
            text = await websocket.receive_text()
            try:
                msg = json.loads(text)
            except Exception:
                await websocket.send_text(
                    json.dumps({"type": "error", "message": "Invalid JSON format"})
                )
                continue

            msg_type = msg.get("type", "update")

            if msg_type == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
                continue

            elif msg_type == "stop":
                uid = msg.get("user_id") or connected_user_id
                if uid:
                    await remove_location(uid)
                await websocket.send_text(
                    json.dumps({"type": "stopped", "message": "Location sharing stopped"})
                )
                continue

            elif msg_type == "update":
                data = msg.get("data", msg)
                try:
                    update_obj = LocationUpdate(**data)
                except Exception as val_err:
                    await websocket.send_text(
                        json.dumps({"type": "error", "message": f"Validation error: {val_err}"})
                    )
                    continue

                connected_user_id = update_obj.user_id
                stored = await store_location(update_obj)

                # Check Geofence
                geofence = check_geofence(
                    lat=update_obj.latitude,
                    lon=update_obj.longitude,
                    center_lat=update_obj.safe_zone_center_lat,
                    center_lon=update_obj.safe_zone_center_lon,
                    radius_meters=update_obj.safe_zone_radius_meters,
                )

                # Fetch peers
                peers = await get_nearby_peers(
                    user_id=update_obj.user_id,
                    lat=update_obj.latitude,
                    lon=update_obj.longitude,
                    radius_km=10.0,
                )

                response_payload = {
                    "type": "ack",
                    "status": "stored",
                    "geofence": geofence.model_dump(),
                    "peers": [p.model_dump() for p in peers],
                    "timestamp": stored.get("timestamp"),
                }
                await websocket.send_text(json.dumps(response_payload))

    except WebSocketDisconnect:
        logger.info(f"WebSocket client disconnected: {connected_user_id}")
        if connected_user_id:
            await remove_location(connected_user_id)
    except Exception as exc:
        logger.warning(f"WebSocket error: {exc}")
        if connected_user_id:
            await remove_location(connected_user_id)

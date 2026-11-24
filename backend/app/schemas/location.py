from typing import Optional
from pydantic import BaseModel, Field


class LocationUpdate(BaseModel):
    user_id: str = Field(..., description="Unique user or device ID")
    display_name: Optional[str] = Field("User", description="User display name")
    latitude: float = Field(..., ge=-90.0, le=90.0, description="GPS Latitude")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="GPS Longitude")
    accuracy: Optional[float] = Field(None, description="Accuracy in meters")
    heading: Optional[float] = Field(None, description="Heading in degrees")
    speed: Optional[float] = Field(None, description="Speed in m/s")
    timestamp: str = Field(..., description="ISO 8601 timestamp")
    is_sharing: bool = Field(True, description="Whether location sharing is active")
    safe_zone_radius_meters: Optional[float] = Field(500.0, description="Geofence safe zone radius in meters")
    safe_zone_center_lat: Optional[float] = Field(None, description="Center latitude of geofence safe zone")
    safe_zone_center_lon: Optional[float] = Field(None, description="Center longitude of geofence safe zone")


class PeerLocation(BaseModel):
    user_id: str
    display_name: str
    latitude: float
    longitude: float
    distance_meters: Optional[float] = None
    updated_at: str
    is_sharing: bool = True
    status: str = "active"


class PeersResponse(BaseModel):
    peers: list[PeerLocation]
    count: int
    user_latitude: float
    user_longitude: float
    search_radius_km: float


class GeofenceStatus(BaseModel):
    in_safe_zone: bool
    distance_from_center_meters: float
    safe_zone_radius_meters: float
    alert_triggered: bool
    message: str


class StopSharingRequest(BaseModel):
    user_id: str

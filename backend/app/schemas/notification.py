from typing import Optional
from pydantic import BaseModel, Field

# Notification categories
CATEGORY_EMERGENCY_SOS = "emergency_sos"
CATEGORY_SAFETY_TIP = "safety_tip"
CATEGORY_APP_UPDATE = "app_update"
CATEGORY_RADAR_ALERT = "radar_alert"

VALID_CATEGORIES = {
    CATEGORY_EMERGENCY_SOS,
    CATEGORY_SAFETY_TIP,
    CATEGORY_APP_UPDATE,
    CATEGORY_RADAR_ALERT,
}


class PushNotificationRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=150, description="Push notification title")
    body: str = Field(..., min_length=1, max_length=500, description="Push notification body text")
    category: str = Field(CATEGORY_EMERGENCY_SOS, description="Category of notification")
    target_user_ids: Optional[list[str]] = Field(None, description="Optional list of target user IDs")
    fcm_tokens: Optional[list[str]] = Field(None, description="Optional direct list of FCM device tokens")
    data: Optional[dict[str, str]] = Field(default_factory=dict, description="Arbitrary custom key-value payload")
    is_data_only: bool = Field(False, description="Silent/data-only push without top notification banner")


class PushNotificationResponse(BaseModel):
    status: str
    message: str
    success_count: int
    failure_count: int
    category: str
    is_data_only: bool
    analytics_event: str = "notification_sent"
    dispatched_at: str


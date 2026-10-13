import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class ScanEvent(Base):
    __tablename__ = "scan_events"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    qr_uid: Mapped[str] = mapped_column(String(16), nullable=False, index=True)

    # ── Responder info (optional, self-reported) ───────────────────────────
    responder_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    responder_hospital: Mapped[str | None] = mapped_column(String(200), nullable=True)

    # ── Location ───────────────────────────────────────────────────────────
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_area: Mapped[str | None] = mapped_column(String(300), nullable=True)
    google_maps_url: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Device / UA ────────────────────────────────────────────────────────
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
    device_type: Mapped[str | None] = mapped_column(String(50), nullable=True)
    # "mobile" | "desktop" | "tablet" | "unknown"

    # ── Notification status ────────────────────────────────────────────────
    sms_sent: Mapped[bool] = mapped_column(Boolean, default=False)
    whatsapp_sent: Mapped[bool] = mapped_column(Boolean, default=False)
    fcm_sent: Mapped[bool] = mapped_column(Boolean, default=False)
    email_sent: Mapped[bool] = mapped_column(Boolean, default=False)
    notification_suppressed: Mapped[bool] = mapped_column(
        Boolean, default=False
    )  # True = dedup fired, no notification sent

    # ── False alarm ────────────────────────────────────────────────────────
    is_false_alarm: Mapped[bool] = mapped_column(Boolean, default=False)

    # ── Timestamp ─────────────────────────────────────────────────────────
    scanned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        index=True,
    )

    # ── Relationships ──────────────────────────────────────────────────────
    user: Mapped["User"] = relationship("User", back_populates="scan_events")  # type: ignore[name-defined]  # noqa: F821

    def __repr__(self) -> str:
        return f"<ScanEvent qr_uid={self.qr_uid} scanned_at={self.scanned_at}>"

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class EmergencyContact(Base):
    __tablename__ = "emergency_contacts"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # ── Contact info ───────────────────────────────────────────────────────
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    relation: Mapped[str] = mapped_column(String(100), nullable=False)
    phone: Mapped[str] = mapped_column(String(20), nullable=False)  # E.164

    # ── Notification preferences ───────────────────────────────────────────
    whatsapp_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    notify_on_scan: Mapped[bool] = mapped_column(Boolean, default=True)

    # ── Order (for display) ────────────────────────────────────────────────
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    # ── Timestamps ────────────────────────────────────────────────────────
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # ── Relationships ──────────────────────────────────────────────────────
    user: Mapped["User"] = relationship("User", back_populates="emergency_contacts")  # type: ignore[name-defined]  # noqa: F821

    def __repr__(self) -> str:
        return f"<EmergencyContact name={self.name} phone={self.phone}>"

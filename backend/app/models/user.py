import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    # ── Primary key ────────────────────────────────────────────────────────
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )

    # ── Identity ───────────────────────────────────────────────────────────
    phone: Mapped[str | None] = mapped_column(
        String(20), unique=True, nullable=True, index=True
    )  # E.164 format: +91XXXXXXXXXX
    email: Mapped[str | None] = mapped_column(
        String(255), unique=True, nullable=True, index=True
    )
    google_id: Mapped[str | None] = mapped_column(
        String(128), unique=True, nullable=True, index=True
    )

    # ── FCM ───────────────────────────────────────────────────────────────
    fcm_token: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Refresh token (server-side revocation) ─────────────────────────────
    refresh_token_hash: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── DPDPA consent ─────────────────────────────────────────────────────
    consent_given: Mapped[bool] = mapped_column(Boolean, default=False)
    consent_timestamp: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

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
    profile: Mapped["Profile"] = relationship(  # type: ignore[name-defined]  # noqa: F821
        "Profile", back_populates="user", uselist=False, cascade="all, delete-orphan", lazy="selectin"
    )
    emergency_contacts: Mapped[list["EmergencyContact"]] = relationship(  # type: ignore[name-defined]  # noqa: F821
        "EmergencyContact", back_populates="user", cascade="all, delete-orphan", lazy="selectin"
    )
    scan_events: Mapped[list["ScanEvent"]] = relationship(  # type: ignore[name-defined]  # noqa: F821
        "ScanEvent", back_populates="user", cascade="all, delete-orphan"
    )
    documents: Mapped[list["Document"]] = relationship(  # type: ignore[name-defined]  # noqa: F821
        "Document", back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} phone={self.phone} email={self.email}>"

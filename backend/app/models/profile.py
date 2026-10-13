import uuid
from datetime import date, datetime, timezone

from sqlalchemy import (
    ARRAY,
    Boolean,
    Date,
    DateTime,
    ForeignKey,
    JSON,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Profile(Base):
    __tablename__ = "profiles"

    # ── Primary key ────────────────────────────────────────────────────────
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # ── QR ─────────────────────────────────────────────────────────────────
    qr_uid: Mapped[str | None] = mapped_column(
        String(16), unique=True, nullable=True, index=True
    )  # 8-char random alphanumeric e.g. "X7K2M9QP"
    qr_is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # ── Personal ───────────────────────────────────────────────────────────
    full_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    date_of_birth: Mapped[date | None] = mapped_column(Date, nullable=True)
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    photo_url: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Critical medical ───────────────────────────────────────────────────
    blood_group: Mapped[str | None] = mapped_column(String(10), nullable=True)
    # e.g. ["Penicillin", "Dust"]
    allergies: Mapped[list[str] | None] = mapped_column(ARRAY(Text), nullable=True)
    # e.g. ["Diabetes Type 2", "Hypertension"]
    chronic_conditions: Mapped[list[str] | None] = mapped_column(
        ARRAY(Text), nullable=True
    )

    # ── Medications ────────────────────────────────────────────────────────
    # [{name, dosage, frequency}]
    medications: Mapped[list[dict] | None] = mapped_column(JSON, nullable=True)

    # ── Medical history ────────────────────────────────────────────────────
    past_surgeries: Mapped[list[str] | None] = mapped_column(ARRAY(Text), nullable=True)
    implants: Mapped[list[str] | None] = mapped_column(ARRAY(Text), nullable=True)
    is_organ_donor: Mapped[bool] = mapped_column(Boolean, default=False)

    # ── Primary physician ──────────────────────────────────────────────────
    doctor_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    doctor_phone: Mapped[str | None] = mapped_column(String(20), nullable=True)

    # ── Privacy toggles ────────────────────────────────────────────────────
    show_name: Mapped[bool] = mapped_column(Boolean, default=True)
    show_dob: Mapped[bool] = mapped_column(Boolean, default=True)
    show_photo: Mapped[bool] = mapped_column(Boolean, default=True)

    # ── Profile completion ─────────────────────────────────────────────────
    wizard_completed: Mapped[bool] = mapped_column(Boolean, default=False)

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
    user: Mapped["User"] = relationship("User", back_populates="profile")  # type: ignore[name-defined]  # noqa: F821

    def __repr__(self) -> str:
        return f"<Profile user_id={self.user_id} qr_uid={self.qr_uid}>"

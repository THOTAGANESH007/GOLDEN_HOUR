"""
models/__init__.py — import all models here so Alembic auto-detects them.
"""

from app.models.user import User
from app.models.profile import Profile
from app.models.emergency_contact import EmergencyContact
from app.models.scan_event import ScanEvent
from app.models.document import Document

__all__ = ["User", "Profile", "EmergencyContact", "ScanEvent", "Document"]

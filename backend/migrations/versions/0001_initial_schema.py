"""initial_schema

Revision ID: 0001_initial_schema
Revises: None
Create Date: 2026-10-13 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '0001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ── 1. Users ──────────────────────────────────────────────────────────────
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('fcm_token', sa.Text(), nullable=True),
        sa.Column('refresh_token_hash', sa.Text(), nullable=True),
        sa.Column('consent_given', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('consent_timestamp', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index('ix_users_phone', 'users', ['phone'], unique=True)

    # ── 2. Profiles ───────────────────────────────────────────────────────────
    op.create_table(
        'profiles',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('qr_uid', sa.String(length=16), nullable=True),
        sa.Column('qr_is_active', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('full_name', sa.String(length=200), nullable=True),
        sa.Column('date_of_birth', sa.Date(), nullable=True),
        sa.Column('gender', sa.String(length=20), nullable=True),
        sa.Column('photo_url', sa.Text(), nullable=True),
        sa.Column('blood_group', sa.String(length=10), nullable=True),
        sa.Column('allergies', sa.ARRAY(sa.Text()), nullable=True),
        sa.Column('chronic_conditions', sa.ARRAY(sa.Text()), nullable=True),
        sa.Column('medications', sa.JSON(), nullable=True),
        sa.Column('past_surgeries', sa.ARRAY(sa.Text()), nullable=True),
        sa.Column('implants', sa.ARRAY(sa.Text()), nullable=True),
        sa.Column('is_organ_donor', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('doctor_name', sa.String(length=200), nullable=True),
        sa.Column('doctor_phone', sa.String(length=20), nullable=True),
        sa.Column('show_name', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('show_dob', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('show_photo', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('wizard_completed', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('ix_profiles_user_id', 'profiles', ['user_id'], unique=True)
    op.create_index('ix_profiles_qr_uid', 'profiles', ['qr_uid'], unique=True)

    # ── 3. Emergency Contacts ─────────────────────────────────────────────────
    op.create_table(
        'emergency_contacts',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=200), nullable=False),
        sa.Column('relation', sa.String(length=100), nullable=False),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('whatsapp_enabled', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('notify_on_scan', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('sort_order', sa.Integer(), server_default=sa.text('0'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('ix_emergency_contacts_user_id', 'emergency_contacts', ['user_id'], unique=False)

    # ── 4. Scan Events ────────────────────────────────────────────────────────
    op.create_table(
        'scan_events',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('qr_uid', sa.String(length=16), nullable=False),
        sa.Column('responder_name', sa.String(length=200), nullable=True),
        sa.Column('responder_hospital', sa.String(length=200), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('location_area', sa.String(length=300), nullable=True),
        sa.Column('google_maps_url', sa.Text(), nullable=True),
        sa.Column('user_agent', sa.Text(), nullable=True),
        sa.Column('device_type', sa.String(length=50), nullable=True),
        sa.Column('sms_sent', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('whatsapp_sent', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('fcm_sent', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('email_sent', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('notification_suppressed', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('is_false_alarm', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('scanned_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('ix_scan_events_user_id', 'scan_events', ['user_id'], unique=False)
    op.create_index('ix_scan_events_qr_uid', 'scan_events', ['qr_uid'], unique=False)
    op.create_index('ix_scan_events_scanned_at', 'scan_events', ['scanned_at'], unique=False)

    # ── 5. Documents ──────────────────────────────────────────────────────────
    op.create_table(
        'documents',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('file_name', sa.String(length=300), nullable=False),
        sa.Column('file_type', sa.String(length=50), nullable=False),
        sa.Column('mime_type', sa.String(length=100), nullable=False),
        sa.Column('file_size_bytes', sa.BigInteger(), nullable=False),
        sa.Column('storage_path', sa.Text(), nullable=False),
        sa.Column('public_url', sa.Text(), nullable=True),
        sa.Column('uploaded_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('ix_documents_user_id', 'documents', ['user_id'], unique=False)


def downgrade() -> None:
    op.drop_table('documents')
    op.drop_table('scan_events')
    op.drop_table('emergency_contacts')
    op.drop_table('profiles')
    op.drop_table('users')

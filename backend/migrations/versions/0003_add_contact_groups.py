"""add_contact_groups

Revision ID: 0003_add_contact_groups
Revises: 0002_add_google_auth_fields
Create Date: 2026-11-24 10:45:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = '0003_add_contact_groups'
down_revision: Union[str, None] = '0002_add_google_auth_fields'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create contact_groups table
    op.create_table(
        'contact_groups',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('description', sa.String(length=255), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
    )
    op.create_index('ix_contact_groups_user_id', 'contact_groups', ['user_id'], unique=False)

    # 2. Add group_id to emergency_contacts
    op.add_column(
        'emergency_contacts',
        sa.Column('group_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('contact_groups.id', ondelete='SET NULL'), nullable=True)
    )
    op.create_index('ix_emergency_contacts_group_id', 'emergency_contacts', ['group_id'], unique=False)


def downgrade() -> None:
    op.drop_index('ix_emergency_contacts_group_id', table_name='emergency_contacts')
    op.drop_column('emergency_contacts', 'group_id')
    op.drop_index('ix_contact_groups_user_id', table_name='contact_groups')
    op.drop_table('contact_groups')


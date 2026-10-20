"""add_google_auth_fields

Revision ID: 0002_add_google_auth_fields
Revises: 0001_initial_schema
Create Date: 2026-10-20 19:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '0002_add_google_auth_fields'
down_revision: Union[str, None] = '0001_initial_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Make phone nullable
    op.alter_column('users', 'phone', existing_type=sa.String(length=20), nullable=True)

    # 2. Add email and google_id
    op.add_column('users', sa.Column('email', sa.String(length=255), nullable=True))
    op.add_column('users', sa.Column('google_id', sa.String(length=128), nullable=True))

    # 3. Create unique indices
    op.create_index('ix_users_email', 'users', ['email'], unique=True)
    op.create_index('ix_users_google_id', 'users', ['google_id'], unique=True)


def downgrade() -> None:
    op.drop_index('ix_users_google_id', table_name='users')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_column('users', 'google_id')
    op.drop_column('users', 'email')
    op.alter_column('users', 'phone', existing_type=sa.String(length=20), nullable=False)

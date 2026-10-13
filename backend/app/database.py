from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import get_settings

settings = get_settings()

# ── Engine ─────────────────────────────────────────────────────────────────────
engine = create_async_engine(
    settings.database_url,
    echo=not settings.is_production,   # SQL logging in dev only
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

# ── Session factory ────────────────────────────────────────────────────────────
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


# ── Base model ─────────────────────────────────────────────────────────────────
class Base(DeclarativeBase):
    """All SQLAlchemy models must inherit from this."""
    pass


# ── Dependency ─────────────────────────────────────────────────────────────────
async def get_db() -> AsyncSession:  # type: ignore[override]
    """FastAPI dependency — yields a DB session and guarantees close."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── JWT ────────────────────────────────────────────────────────────────
    secret_key: str = "change-me-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30

    # ── Supabase ───────────────────────────────────────────────────────────
    supabase_url: str = ""
    supabase_service_key: str = ""
    database_url: str = ""          # asyncpg DSN

    # ── Redis (Upstash) ────────────────────────────────────────────────────
    redis_url: str = "redis://localhost:6379"

    # ── Notifications ──────────────────────────────────────────────────────
    fast2sms_api_key: str = ""

    # ── WhatsApp (Green-API) ───────────────────────────────────────────────
    green_api_instance_id: str = ""
    green_api_token: str = ""
    green_api_host: str = "https://api.green-api.com"

    firebase_credentials_json: str = "./firebase-service-account.json"

    resend_api_key: str = ""
    from_email: str = "alerts@goldenhr.in"

    # ── Sentry ─────────────────────────────────────────────────────────────
    sentry_dsn: str = ""

    # ── Rate limiting / dedup ──────────────────────────────────────────────
    max_scans_per_qr_per_hour: int = 20
    notification_dedup_minutes: int = 5

    # ── App ────────────────────────────────────────────────────────────────
    app_base_url: str = "https://goldenhr.pages.dev"
    app_env: str = "development"         # "development" | "production"

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"


@lru_cache
def get_settings() -> Settings:
    """Cached singleton — import and call this everywhere."""
    return Settings()

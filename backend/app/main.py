"""
Golden Hour — FastAPI Application Entry Point
"""
import sentry_sdk
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.config import get_settings
from app.middleware.rate_limiter import limiter

# ── Routers ────────────────────────────────────────────────────────────────────
from app.api.v1.auth import router as auth_router
from app.api.v1.profile import router as profile_router
from app.api.v1.qr import router as qr_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.documents import router as documents_router
from app.api.v1.scan_events import router as scan_events_router

settings = get_settings()

# ── Sentry ─────────────────────────────────────────────────────────────────────
if settings.sentry_dsn:
    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        traces_sample_rate=0.2,
        environment=settings.app_env,
    )

# ── App factory ────────────────────────────────────────────────────────────────
app = FastAPI(
    title="Golden Hour API",
    description=(
        "Universal Medical Emergency QR Code System — "
        "scan a QR → get critical medical info instantly → notify family."
    ),
    version="1.0.0",
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
)

# ── Rate limiter ───────────────────────────────────────────────────────────────
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ── CORS ───────────────────────────────────────────────────────────────────────
ALLOWED_ORIGINS = [
    "https://goldenhr.pages.dev",
    "https://goldenhr.ganeshthota656.workers.dev",
    "http://localhost:3000",
    "http://localhost:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_origin_regex=r"^https://.*\.(pages|workers)\.dev$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routes ─────────────────────────────────────────────────────────────────────
API_PREFIX = "/api/v1"

app.include_router(auth_router, prefix=API_PREFIX)
app.include_router(profile_router, prefix=API_PREFIX)
app.include_router(qr_router, prefix=API_PREFIX)
app.include_router(notifications_router, prefix=API_PREFIX)
app.include_router(documents_router, prefix=API_PREFIX)
app.include_router(scan_events_router, prefix=API_PREFIX)


# ── Health check ───────────────────────────────────────────────────────────────
@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "Golden Hour API",
        "version": "1.0.0",
        "env": settings.app_env,
    }


# ── Privacy Policy ────────────────────────────────────────────────────────────
from fastapi.responses import HTMLResponse

@app.get("/privacy", tags=["Legal"], response_class=HTMLResponse)
async def privacy_policy():
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Privacy Policy - Golden Hour</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #333; }
            h1 { color: #d32f2f; }
            h2 { color: #1976d2; margin-top: 24px; }
            p { margin-bottom: 16px; }
        </style>
    </head>
    <body>
        <h1>Privacy Policy for Golden Hour</h1>
        <p><strong>Effective Date:</strong> October 2026</p>
        <p>Golden Hour is committed to protecting your privacy and medical information. This Privacy Policy describes how we handle information in our universal medical emergency QR code application.</p>
        <h2>1. Information We Collect</h2>
        <p>We collect essential emergency contact details and medical info you choose to disclose (such as blood group, allergies, emergency contacts) to display to first responders during an emergency.</p>
        <h2>2. How We Use Information</h2>
        <p>Information is used solely to provide life-saving alerts and critical details during emergency QR code scans.</p>
        <h2>3. Data Deletion</h2>
        <p>Users may request complete deletion of their account and emergency profile at any time through the app or by contacting support at support@goldenhr.in.</p>
        <h2>4. Contact Us</h2>
        <p>If you have any questions, contact us at support@goldenhr.in.</p>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content, status_code=200)


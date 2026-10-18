import ssl
from celery import Celery
from app.config import get_settings

settings = get_settings()

redis_url = settings.redis_url
if redis_url.startswith("rediss://") and "ssl_cert_reqs" not in redis_url:
    separator = "&" if "?" in redis_url else "?"
    redis_url = f"{redis_url}{separator}ssl_cert_reqs=CERT_NONE"

celery_app = Celery(
    "golden_hour",
    broker=redis_url,
    backend=redis_url,
    include=["app.tasks.notification_tasks"],
)

celery_config = dict(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_acks_late=True,                 # Only ack after success/failure
    task_reject_on_worker_lost=True,     # Re-queue if worker dies
    worker_prefetch_multiplier=1,        # Fair dispatch
    task_default_retry_delay=5,          # seconds
    task_max_retries=3,
)

if redis_url.startswith("rediss://"):
    celery_config["broker_use_ssl"] = {"ssl_cert_reqs": ssl.CERT_NONE}
    celery_config["redis_backend_use_ssl"] = {"ssl_cert_reqs": ssl.CERT_NONE}

celery_app.conf.update(celery_config)

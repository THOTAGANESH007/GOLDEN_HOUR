from celery import Celery
from app.config import get_settings

settings = get_settings()

celery_app = Celery(
    "golden_hour",
    broker=settings.redis_url,
    backend=settings.redis_url,
    include=["app.tasks.notification_tasks"],
)

celery_app.conf.update(
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

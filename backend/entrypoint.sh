#!/bin/sh
set -e

echo "[Golden Hour] Ensuring uploads directory exists..."
mkdir -p /app/uploads

echo "[Golden Hour] Running database migrations..."
alembic upgrade head

echo "[Golden Hour] Starting Celery worker in background..."
celery -A app.tasks.celery_app worker --loglevel=info -c 2 &

echo "[Golden Hour] Starting Uvicorn web server..."
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"

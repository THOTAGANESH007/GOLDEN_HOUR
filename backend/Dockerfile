FROM python:3.12-slim

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Expose port
EXPOSE 8000

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Start: run entrypoint script (Alembic -> Celery background worker -> Uvicorn)
ENTRYPOINT ["/app/entrypoint.sh"]

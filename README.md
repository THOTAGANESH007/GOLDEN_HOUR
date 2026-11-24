# 🏥 Golden Hour

> **Universal Emergency Safety QR Code & ICE Notification Platform**  
> *Compliant with India Digital Personal Data Protection Act (DPDPA 2023)*

Scan a QR code → get critical non-clinical emergency safety profile instantly → notify designated ICE (In Case of Emergency) contacts automatically via WhatsApp & SMS.  
**No app required for first responders or bystanders.** Built for the golden hour of trauma and medical emergency response.

---

## 🏛️ Monorepo Architecture

```
GOLDEN_HOUR/
├── apps/
│   ├── mobile/            # Flutter patient emergency safety app (Android/iOS)
│   ├── responder-web/     # React emergency profile web interface (zero-install responder portal)
│   └── admin-web/         # React + Vite hospital & admin monitoring portal (port 3000)
├── backend/               # FastAPI async REST API & WebSocket server (port 8000)
├── docs/                  # Architecture blueprints, enhancements, and statutory documentation
├── docker-compose.yml     # Multi-container orchestration (FastAPI + Postgres + Redis + Admin Web)
└── .env.example           # Canonical environment configuration template
```

---

## 🐳 Docker Compose Quick-Start (Local Development)

The easiest way to spin up the entire Golden Hour local development stack (Backend, Database, Cache, and Admin Web) is using Docker Compose.

### 1. Prerequisites
- [Docker](https://docs.docker.com/get-docker/) (v24.0+)
- [Docker Compose](https://docs.docker.com/compose/) (v2.20+)

### 2. Configure Environment
Copy the canonical environment template to `.env`:

```bash
cp .env.example .env
```

*(Optional)* Adjust database credentials or API keys in `.env` if desired. The defaults work out of the box for local development.

### 3. Launch All Services

```bash
docker compose up -d --build
```

### 4. Service Port Mapping

| Service | Port | URL / Access | Description |
|---|---|---|---|
| **Backend API** | `8000` | [http://localhost:8000/docs](http://localhost:8000/docs) | FastAPI OpenAPI interactive documentation |
| **Backend Health** | `8000` | [http://localhost:8000/health](http://localhost:8000/health) | System health & readiness endpoint |
| **Admin Web UI** | `3000` | [http://localhost:3000](http://localhost:3000) | Hospital and emergency dispatch admin dashboard |
| **PostgreSQL** | `5432` | `localhost:5432` | PostgreSQL 15 database (`goldenhour`) |
| **Redis** | `6379` | `localhost:6379` | Redis 7 cache & session broker |

### 5. Running Database Migrations

Database migrations run automatically on container startup via `entrypoint.sh`. To manually run or inspect migrations inside Docker:

```bash
# Run latest Alembic database migrations
docker compose exec backend alembic upgrade head

# Inspect migration history
docker compose exec backend alembic current
```

### 6. Managing the Local Stack

```bash
# View live streaming logs across all containers
docker compose logs -f

# View backend logs only
docker compose logs -f backend

# Restart a specific service
docker compose restart backend

# Stop all containers (preserving persistent database volumes)
docker compose down

# Stop and wipe database volumes (clean reset)
docker compose down -v
```

---

## 🧪 Running Tests Locally

### Mobile App (Flutter)
```bash
cd apps/mobile
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

### Backend API (Python)
```bash
cd backend
source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
ruff check .
pytest tests -v --cov=app
```

---

## 🛡️ India DPDPA 2023 Statutory Compliance

Golden Hour operates strictly as a **non-clinical emergency safety profile and ICE notification platform**.
- **Non-Clinical Positioning**: The platform does not perform clinical triage, diagnosis, medication prescription, or medical treatment.
- **Data Minimization & Consent**: Emergency profile creation requires explicit digital consent pursuant to Section 6 of India DPDPA 2023.
- **Privacy Toggles**: Users maintain granular control over public responder visibility (`show_name`, `show_dob`, `show_photo`).
- **Right to Erasure**: Complete account and emergency data deletion is provided via `DELETE /api/v1/auth/delete-account` under Section 12 of DPDPA 2023.

---

## 📄 License
Copyright © 2026 Golden Hour Platform. All rights reserved.

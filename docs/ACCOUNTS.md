# 🔐 Golden Hour — Accounts & Infrastructure Setup Guide

This document maintains the credentials mapping, connectivity status, setup instructions, and account checklists for all external cloud services powering the **Golden Hour** system.

---

## 📊 Account Status Checklist

| Service | Category | Status | Tested & Verified | Notes |
|---|---|:---:|:---:|---|
| **Oracle Cloud (OCI)** | Compute & Host (VM) | ✅ **Active** | 2026-10-20 | Always-Free `VM.Standard.E2.1.Micro` (Ubuntu 24.04, IP `129.225.91.215`), Caddy HTTPS with Let's Encrypt |
| **PostgreSQL 16** | Relational Database | ✅ **Active** | 2026-10-20 | Local Docker container (`golden-hour-db`) on persistent SSD volume (`~/postgres_data`), isolated on `golden-net` |
| **Local Redis** | Celery Task Broker | ✅ **Active** | 2026-10-20 | Local Docker container (`golden-hour-redis`) on `golden-net`, sub-ms latency, ₹0 cost |
| **Firebase** | Google Auth & Push (FCM) | ✅ **Active** | 2026-10-20 | Project `goldenhour-7d0ed`, 1-Tap Google Sign-In + real-time emergency push notifications |
| **Cloudflare Pages** | Responder Web Hosting | ✅ **Active** | 2026-10-18 | Live on `https://goldenhr.pages.dev` & `https://goldenhr.ganeshthota656.workers.dev` |
| **Document Storage** | Local NVMe SSD / R2 | ✅ **Migrated** | 2026-10-20 | Zero external cost, persistent NVMe host volume (`~/documents_data` -> `/app/uploads`), served via FastAPI FileResponse |
| **WhatsApp (Meta Cloud API)** | Primary Emergency Alert | ✅ **Migrated** | 2026-10-21 | Official Meta Graph API v21.0, 1,000 free sessions/month, verified sender |
| **Fast2SMS** | Offline Safety Net (SMS) | ✅ **Active** | 2026-10-21 | ₹50 balance (~200 SMS), automated fallback when contact has no mobile data |
| **Twilio & Green-API** | Third-party Bridges | ❌ *Decommissioned* | 2026-10-21 | 100% removed in favor of Firebase Auth, Meta WhatsApp, and Fast2SMS safety net |
| **Resend** | Email Fallback | ✅ **Active** | 2026-10-14 | API key authenticated with sending permission |
| **Sentry** | Error Monitoring | ✅ **Active** | 2026-10-14 | DSN verified; test diagnostics event dispatched |
| **DuckDNS** | Free Dynamic DNS | ✅ **Active** | 2026-10-20 | `goldenhour-backend.duckdns.org` pointing to OCI VM IP |
| **Google Play Console** | Store Release | ⏳ *Pending* | — | *Account ready for release track upload* |

---

## 🛠️ Service Setup Documentation

### 1. Oracle Cloud Infrastructure (Always-Free Compute & Hosting)
* **Instance Type:** `VM.Standard.E2.1.Micro` (Always Free, AMD 64-bit, 1 GB RAM, 44 GB NVMe SSD)
* **Public IP:** `129.225.91.215`
* **Operating System:** Ubuntu 24.04 LTS
* **Reverse Proxy:** Caddy v2 with automated Let's Encrypt TLS 1.3 / HTTP/2 SSL
* **Domain:** `https://goldenhour-backend.duckdns.org`
* **Docker Network:** `golden-net` (isolates API, Database, Redis, and Celery)
* **Zero Cold Starts:** Runs 24/7 with zero sleeping or warm-up delays.

---

### 2. PostgreSQL 16 (Local High-Performance Database)
* **Container:** `golden-hour-db` (Image: `postgres:16-alpine`)
* **Storage Volume:** `~/postgres_data` (permanent host SSD directory)
* **Tables:** `users`, `profiles`, `emergency_contacts`, `scan_events`, `documents`, `alembic_version`
* **Connection String:** `postgresql+asyncpg://postgres:<password>@golden-hour-db:5432/golden_hour`
* **Security:** Port `5432` is private to `golden-net` and shielded from public internet exposure.

---

### 3. Local Redis (Ultra-Fast Task Broker & Cache)
* **Container:** `golden-hour-redis` (Image: `redis:alpine`)
* **Network:** `golden-net`
* **Connection String:** `redis://golden-hour-redis:6379/0`
* **Latency:** < 0.5ms (in-memory hardware bus, replaces Upstash)
* **Used by:** Celery background worker for dispatching Push notifications, WhatsApp, and SMS alerts.

---

### 4. Document Storage (Local NVMe SSD & Cloudflare R2 Compatible)
* **Status:** ✅ **Migrated from Supabase Storage**
* **Storage Location:** Persistent host directory `~/documents_data` mounted to `/app/uploads` in Docker
* **Cost:** ₹0 forever (utilizes Oracle Cloud's free 44 GB NVMe SSD)
* **Performance:** Sub-millisecond disk writes, zero bandwidth egress charges, zero external rate limits
* **Streaming Endpoint:** `GET /api/v1/documents/raw/{storage_path}` and `GET /api/v1/documents/{doc_id}/raw`
  - Returns `FileResponse` with HTTP Range support for seamless PDF page streaming and image rendering in Flutter `CachedNetworkImage` and Google Docs Viewer
  - Built-in path traversal security (`is_relative_to` upload directory verification)
* **Cloudflare R2 / S3 Ready:** Supports optional S3/R2 endpoints via `STORAGE_BACKEND=r2` if off-server replication is ever desired.

---

### 5. Fast2SMS (Emergency SMS to Family)
* **Website:** [fast2sms.com](https://www.fast2sms.com)
* **Route:** Quick SMS (`route: q`)
* **Target:** 10-digit Indian numbers (`+91` prefix automatically stripped)
* **Message format:**
  > `EMERGENCY ALERT: <Patient>'s medical QR was scanned. Time: <HH:MM IST> | <Google Maps URL> Responder: <Name>. Please call 108 immediately. - Golden Hour`
* **Alternative & Migration Plan:** **TextBee Android Gateway / Firebase Push (FCM)**
  - Family members with the app installed receive **100% free, unlimited, instant high-priority Push alerts** via FCM.
  - For SMS to non-app users: Replace paid Fast2SMS gateway with **TextBee** (`textbee.dev`), routing SMS through an Android phone with a carrier SIM (Jio / Airtel provides 100 free SMS/day = 3,000 free SMS/month).

---

### 6. WhatsApp Emergency Alerts (Official Meta Cloud API)
* **Architecture:** 100% official server-to-server messaging via **Meta WhatsApp Cloud API (Graph API v21.0)**.
* **Portal:** [developers.facebook.com](https://developers.facebook.com)
* **Endpoint:** `POST https://graph.facebook.com/v21.0/{WHATSAPP_PHONE_NUMBER_ID}/messages`
* **Free Tier:** 1,000 free service conversations every month directly from Meta.
* **Configuration (`backend/.env`):**
  ```env
  WHATSAPP_ACCESS_TOKEN=your_meta_system_user_access_token
  WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id
  WHATSAPP_BUSINESS_ACCOUNT_ID=your_waba_id
  ```
* **Offline Fallback:** If WhatsApp delivery fails or the recipient has no data, Golden Hour automatically routes emergency alerts through **Fast2SMS** as the carrier SMS safety net.

---

### 7. Twilio (Decommissioned)
* **Status:** ❌ **Decommissioned**
* **Replacement:** Replaced by **Firebase Google 1-Tap Sign-In** (`POST /api/v1/auth/google`) and fallback WhatsApp alerts, eliminating Twilio's $0.05/SMS fee and $1.15/month US phone number rental charges.

---

### 5. Firebase (Google Sign-In & High-Priority Push Alerts)
* **Console:** [console.firebase.google.com](https://console.firebase.google.com)
* **Project ID:** `goldenhour-7d0ed`
* **Features Configured:**
  - **1-Tap Google Sign-In:** SHA-1 certificate hashes added for release & debug keystores; Web Client ID `226834628996-j852ld7lg3j4hf0m7cvc5fh2ccf1rnor.apps.googleusercontent.com`
  - **Emergency Push (FCM):** High-priority `emergency_alerts` notification channel with vibration, sound, and instant dispatching to both patients and emergency contacts.
* **Files Configured:**
  - `backend/firebase-service-account.json` (Admin SDK private key for backend dispatching)
  - `apps/mobile/android/app/google-services.json` (Client configuration for Flutter)

---

### 6. Resend (Emergency Email Fallback)
* **Website:** [resend.com](https://resend.com)
* **Scope:** Sending access (`re_...`)
* **Behavior:** Automatically dispatched if SMS fails after 3 retry backoffs.
* **Sender:** `alerts@goldenhr.in` (or test sandbox sender)

---

### 7. Sentry (Error & Crash Reporting)
* **Website:** [sentry.io](https://sentry.io)
* **Ingest Host:** `o4512252566372352.ingest.de.sentry.io`
* **Project ID:** `4512252583739472`
* **Pricing Plan:** 14-day team trial auto-reverts to Developer Plan (**$0 / Free Forever**, 5,000 errors/month, no credit card required).

---

## 🚀 Deployed Production Environments

### ✅ 8.1 Cloudflare Pages & Workers (Responder Web App)
* **Status:** **Live & Deployed**
* **Domains:** 
  - `https://goldenhr.pages.dev`
  - `https://goldenhr.ganeshthota656.workers.dev`
* **Build Configuration:**
  - **Framework preset:** `Vite`
  - **Root directory:** `apps/responder-web`
  - **Build output:** `dist`
  - **Environment Variable:** `VITE_API_BASE_URL=https://goldenhour-backend.duckdns.org/api/v1`

### ✅ 8.2 Oracle Cloud Infrastructure (FastAPI Backend + Database + Redis)
* **Status:** **Live & Deployed**
* **Public IP:** `129.225.91.215`
* **Public Domain:** `https://goldenhour-backend.duckdns.org`
* **SSL Proxy:** Caddy v2 Reverse Proxy with Let's Encrypt TLS 1.3
* **Stack:** Docker containers on `golden-net`:
  - `golden-hour-api` (FastAPI Web Server on port 8000)
  - `golden-hour-db` (PostgreSQL 16 on persistent volume `~/postgres_data`)
  - `golden-hour-redis` (Redis 7 Alpine broker)

---

### ⏳ Step 9: Production Release & Google Play Store

#### 9.1 Health Check Uptime Monitor
* **URL:** `https://goldenhour-backend.duckdns.org/health`
* **Service:** Uptime monitoring (Better Stack / UptimeRobot) pings health check to verify 100% 24/7 availability.

#### 9.2 Google Play Console
1. Go to [play.google.com/console](https://play.google.com/console).
2. Register and pay the one-time $25 developer account fee.
3. Prepare release keystore and export `.aab` for Flutter app release track.

---

## 🔒 Security Guidelines

1. **Never commit secrets:**
   - `backend/.env`
   - `backend/firebase-service-account.json`
   - `apps/responder-web/.env`
   - `apps/mobile/.env`
   All must stay strictly listed inside `.gitignore`.
2. **Database:** Access is restricted via password and Session connection pooler with SSL mode required.
3. **QR Codes:** Contain only an opaque 8-character UID (e.g. `/p/X7K2M9QP`). No patient PII is stored inside QR URLs.

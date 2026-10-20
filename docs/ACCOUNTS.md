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
| **Fast2SMS** | Emergency SMS | ✅ **Active** | 2026-10-14 | ₹50 wallet balance, 200 SMS credits ready |
| **Green-API** | WhatsApp Alerts | ✅ **Active** | 2026-10-14 | Instance `710722764283` is **Authorized** via QR scan |
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

### 3. Fast2SMS (Emergency SMS to Family)
* **Website:** [fast2sms.com](https://www.fast2sms.com)
* **Route:** Quick SMS (`route: q`)
* **Target:** 10-digit Indian numbers (`+91` prefix automatically stripped)
* **Message format:**
  > `EMERGENCY ALERT: <Patient>'s medical QR was scanned. Time: <HH:MM IST> | <Google Maps URL> Responder: <Name>. Please call 108 immediately. - Golden Hour`

---

### 4. Green-API (WhatsApp Emergency Alerts)
* **Website:** [green-api.com](https://green-api.com)
* **Instance ID:** `710722764283`
* **Host:** `https://7107.api.greenapi.com`
* **Status:** `authorized` (linked to WhatsApp via device QR scan)
* **Advantage:** No Facebook account required, no Meta utility template approvals needed.
* **Recipient format:** `<clean_number>@c.us` (e.g. `919876543210@c.us`)

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

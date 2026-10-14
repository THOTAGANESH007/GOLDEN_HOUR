# 🔐 Golden Hour — Accounts & Infrastructure Setup Guide

This document maintains the credentials mapping, connectivity status, setup instructions, and account checklists for all external cloud services powering the **Golden Hour** system.

---

## 📊 Account Status Checklist

| Service | Category | Status | Tested & Verified | Notes |
|---|---|:---:|:---:|---|
| **Supabase** | DB, Auth & Storage | ✅ **Active** | 2026-10-13 | REST API + PostgreSQL 17 Session pooler live; tables migrated |
| **Upstash Redis** | Celery Task Broker | ✅ **Active** | 2026-10-14 | TLS/SSL `rediss://` connection ping successful |
| **Fast2SMS** | Emergency SMS | ✅ **Active** | 2026-10-14 | ₹50 wallet balance, 200 SMS credits ready |
| **Green-API** | WhatsApp Alerts | ✅ **Active** | 2026-10-14 | Instance `710722764283` is **Authorized** via QR scan |
| **Firebase** | Android Push (FCM) | ✅ **Active** | 2026-10-14 | Project `goldenhour-7d0ed`, service account key verified |
| **Resend** | Email Fallback | ✅ **Active** | 2026-10-14 | API key authenticated with sending permission |
| **Sentry** | Error Monitoring | ✅ **Active** | 2026-10-14 | DSN verified; test diagnostics event dispatched |
| **Cloudflare Pages** | Web Hosting (Step 8) | ⏳ *Pending* | — | *To be set up in Step 8* |
| **Render.com** | Backend Hosting (Step 8) | ⏳ *Pending* | — | *To be set up in Step 8* |
| **Better Uptime** | Keep-Warm Ping (Step 9) | ⏳ *Pending* | — | *To be set up in Step 9* |
| **Google Play Console** | Store Release (Step 9) | ⏳ *Pending* | — | *To be set up in Step 9 ($25 fee)* |

---

## 🛠️ Service Setup Documentation

### 1. Supabase (Database, Auth & Storage)
* **Website:** [supabase.com](https://supabase.com)
* **Project Name:** `golden-hour` (Region: `ap-southeast-2`)
* **Tables Created:** `users`, `profiles`, `emergency_contacts`, `scan_events`, `documents`, `alembic_version`
* **Configuration:**
  - `SUPABASE_URL`: `https://trbvfjotjedvzegcyqws.supabase.co`
  - `DATABASE_URL`: Session mode on port 5432 using `postgresql+asyncpg://`
* **Storage Bucket:** Create a public bucket named `documents` in the Supabase Dashboard under Storage.

---

### 2. Upstash Redis (Celery Broker)
* **Website:** [console.upstash.com](https://console.upstash.com)
* **Database Name:** `humble-elk-231845`
* **Protocol:** `rediss://` (TLS encrypted)
* **Used by:** Celery task queue in `backend/app/tasks/celery_app.py` for background dispatching of SMS, WhatsApp, FCM, and Email alerts.

---

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

### 5. Firebase Cloud Messaging (Patient Push Alerts)
* **Console:** [console.firebase.google.com](https://console.firebase.google.com)
* **Project ID:** `goldenhour-7d0ed`
* **Files Configured:**
  - `backend/firebase-service-account.json` (Admin SDK private key)
  - `apps/mobile/android/app/google-services.json` (Client config for Flutter FCM)

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

## 🚀 Steps to Complete Later

### ⏳ Step 8: Cloud Deployment (Cloudflare Pages + Render.com)

#### 8.1 Cloudflare Pages (Responder Web App)
1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → **Workers & Pages** → **Create application** → **Pages** → **Connect to Git**.
2. Select repository: `THOTAGANESH007/GOLDEN_HOUR`.
3. Set build configuration:
   - **Framework preset:** `Vite`
   - **Root directory:** `apps/responder-web`
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
4. Set Environment Variable:
   - `VITE_API_BASE_URL`: `https://<render-service-name>.onrender.com/api/v1`
5. Click **Save and Deploy**.

#### 8.2 Render.com (Backend Web Service)
1. Go to [dashboard.render.com](https://dashboard.render.com) → **New +** → **Web Service**.
2. Connect repository: `THOTAGANESH007/GOLDEN_HOUR`.
3. Set configuration:
   - **Name:** `golden-hour-backend`
   - **Region:** Singapore or Frankfurt
   - **Root Directory:** `backend`
   - **Runtime:** `Docker` (automatically detects `backend/Dockerfile`)
   - **Instance Type:** `Free`
4. Copy all environment variables from `backend/.env` into Render's **Environment** tab.
5. Click **Deploy Web Service**.

---

### ⏳ Step 9: Production Monitoring & Google Play Console

#### 9.1 Better Uptime (Prevent Render Cold Starts)
1. Go to [betterstack.com](https://betterstack.com) → **Uptime**.
2. Add a new HTTP monitor:
   - **URL:** `https://<your-render-url>.onrender.com/health`
   - **Check frequency:** `10 minutes`
   - *This keeps the free Render instance awake so emergency responders experience sub-second response times.*

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

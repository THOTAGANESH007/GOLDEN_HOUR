# ✅ Golden Hour — Implementation Checklist

> **How to use this file:**
> - Mark items as done: change `[ ]` → `[x]`
> - Add the completion date next to each item when done: `[x] Feature Name ✦ 2026-10-13`
> - Add notes or blockers inline using `<!-- note: ... -->`
> - Commit this file after every working session so progress is always tracked

---

## 🏗️ Phase 0 — Project Setup & Accounts

| Status | Task | Completed On |
|--------|------|--------------|
| [x] | GitHub monorepo created & pushed | 2026-10-11 |
| [x] | Folder structure scaffolded (backend, mobile, responder-web, docs) | 2026-10-11 |
| [x] | `.gitignore` configured | 2026-10-11 |
| [x] | Supabase project created | 2026-10-13 |
| [x] | Supabase Phone Auth enabled | 2026-10-18 |
| [x] | Supabase DB tables created (users, profiles, contacts, scan_events, documents) | 2026-10-13 |
| [x] | Supabase Row Level Security (RLS) enabled on all tables | 2026-10-17 |
| [x] | Firebase project created | 2026-10-14 |
| [x] | Firebase Cloud Messaging (FCM) enabled | 2026-10-14 |
| [x] | `google-services.json` downloaded | 2026-10-14 |
| [x] | Cloudflare Pages project created & connected to GitHub | 2026-10-18 |
| [x] | Render.com Web Service created & connected to GitHub | 2026-10-18 |
| [x] | Upstash Redis DB created | 2026-10-14 |
| [x] | Fast2SMS API key obtained | 2026-10-14 |
| [x] | Green-API WhatsApp account & instance created | 2026-10-14 |
| [x] | Green-API linked via WhatsApp QR code | 2026-10-14 |
| [x] | Resend.com API key obtained | 2026-10-14 |
| [x] | Sentry projects created (backend + web) | 2026-10-14 |
| [x] | Better Uptime monitor set up (pings `/health` every 10 min) | 2026-10-18 |
| [x] | Google Play Console account created ($25 fee) | 2026-10-18 |
| [x] | All `.env` files filled with real credentials | 2026-10-14 |

---

## 🔧 Module 0 — Backend Foundation

### Database & Configuration
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | FastAPI project scaffold (`main.py`, `config.py`) | 2026-10-11 |
| [x] | `requirements.txt` created | 2026-10-11 |
| [x] | Python virtual environment set up | 2026-10-13 |
| [x] | `config.py` — reads all env vars via `pydantic-settings` | 2026-10-13 |
| [x] | `database.py` — SQLAlchemy async engine + session factory | 2026-10-13 |
| [x] | Alembic initialized (`alembic init migrations`) | 2026-10-13 |

### SQLAlchemy Models
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `models/user.py` — User model | 2026-10-13 |
| [x] | `models/profile.py` — Patient Profile model | 2026-10-13 |
| [x] | `models/emergency_contact.py` — Emergency Contact model | 2026-10-13 |
| [x] | `models/scan_event.py` — Scan Event model | 2026-10-13 |
| [x] | `models/document.py` — Document model | 2026-10-13 |
| [x] | Alembic initial migration created & tested | 2026-10-13 |
| [x] | All tables created in Supabase DB | 2026-10-13 |

### Pydantic Schemas
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `schemas/auth.py` — OTP request/response schemas | 2026-10-13 |
| [x] | `schemas/profile.py` — Profile create/update/response schemas | 2026-10-13 |
| [x] | `schemas/scan_event.py` — Scan event schemas | 2026-10-13 |

### Middleware & Infrastructure
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `middleware/auth_middleware.py` — JWT validation middleware | 2026-10-13 |
| [x] | `middleware/rate_limiter.py` — `slowapi` rate limiting | 2026-10-13 |
| [x] | CORS configured for Cloudflare + localhost origins | 2026-10-13 |
| [x] | Sentry SDK integrated in backend | 2026-10-13 |
| [x] | `GET /health` endpoint returns `{"status": "healthy"}` | 2026-10-13 |

---

## 🔐 Module 1 — Authentication

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/auth.py` — router file created | 2026-10-13 |
| [x] | `POST /auth/send-otp` — sends OTP via Supabase Auth | 2026-10-13 |
| [x] | `POST /auth/verify-otp` — verifies OTP, returns JWT + refresh token | 2026-10-13 |
| [x] | `POST /auth/refresh` — rotates refresh token → new access token | 2026-10-13 |
| [x] | `POST /auth/logout` — revokes refresh token server-side | 2026-10-13 |
| [x] | `DELETE /auth/delete-account` — hard deletes all user PII | 2026-10-13 |
| [x] | JWT access token (15 min) + refresh token (30 days) working | 2026-10-13 |
| [x] | `services/auth_service.py` — auth business logic isolated | 2026-10-13 |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | GoRouter configured with all routes | 2026-10-17 |
| [x] | Riverpod setup with providers folder | 2026-10-17 |
| [x] | `core/theme/` — app colors, typography, spacing tokens | 2026-10-17 |
| [x] | `core/network/` — Dio HTTP client configured | 2026-10-17 |
| [x] | Dio JWT interceptor (silent token refresh on 401) | 2026-10-17 |
| [x] | `flutter_secure_storage` dependency added | 2026-10-17 |
| [x] | `features/auth/data/auth_remote_source.dart` — API calls | 2026-10-17 |
| [x] | `features/auth/data/auth_repository.dart` — repository layer | 2026-10-17 |
| [x] | `features/auth/domain/auth_provider.dart` — Riverpod provider | 2026-10-17 |
| [x] | `presentation/splash_screen.dart` — JWT check → route decision | 2026-10-17 |
| [x] | `presentation/phone_input_screen.dart` — phone + country code | 2026-10-17 |
| [x] | `presentation/otp_verify_screen.dart` — 6-digit OTP + 60s timer | 2026-10-17 |
| [x] | Auto-login: app opens → valid token → skip login screen | 2026-10-17 |
| [x] | Logout: clears tokens + calls backend logout | 2026-10-17 |

---

## 👤 Module 2 — Patient Profile

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/profile.py` — router file created | 2026-10-13 |
| [x] | `GET /profile/me` — fetch full profile | 2026-10-13 |
| [x] | `PUT /profile/me` — update all profile fields | 2026-10-13 |
| [x] | `PATCH /profile/me/privacy` — update field visibility toggles | 2026-10-13 |
| [x] | `PATCH /profile/me/status` — activate / deactivate QR | 2026-10-13 |
| [x] | `GET /profile/contacts` — list emergency contacts | 2026-10-13 |
| [x] | `POST /profile/contacts` — add emergency contact | 2026-10-13 |
| [x] | `PUT /profile/contacts/{id}` — update contact | 2026-10-13 |
| [x] | `DELETE /profile/contacts/{id}` — remove contact | 2026-10-13 |

### Flutter — Profile Wizard
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | Wizard navigation (step indicator + next/back) | 2026-10-17 |
| [x] | `step1_blood_group.dart` — blood group dropdown | 2026-10-17 |
| [x] | `step2_allergies.dart` — multi-chip allergy input | 2026-10-17 |
| [x] | `step3_conditions.dart` — chronic conditions multi-select + custom | 2026-10-17 |
| [x] | `step4_medications.dart` — medication name + dosage + frequency | 2026-10-17 |
| [x] | `step5_contacts.dart` — emergency contacts (up to 5) + WhatsApp toggle | 2026-10-17 |
| [x] | Profile wizard data submitted to backend on completion | 2026-10-17 |

### Flutter — Profile Screens
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `profile_home_screen.dart` — summary card + completion score | 2026-10-17 |
| [x] | `edit_profile_screen.dart` — full editable form | 2026-10-17 |
| [x] | `privacy_settings_screen.dart` — per-field visibility toggles | 2026-10-17 |
| [x] | `profile_repository.dart` — API integration | 2026-10-17 |
| [x] | `profile_provider.dart` — Riverpod state provider | 2026-10-17 |

---

## 📱 Module 3 — QR Code

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/qr.py` — router file created | 2026-10-13 |
| [x] | `POST /qr/generate` — create 8-char random UID, store mapping | 2026-10-13 |
| [x] | `POST /qr/regenerate` — invalidate old UID, create new | 2026-10-13 |
| [x] | `GET /qr/public/{uid}` — public endpoint (no auth) — returns safe fields | 2026-10-13 |
| [x] | Scan event logged on every call to public endpoint | 2026-10-13 |
| [x] | Rate limiting: 20 scans/hour per QR UID | 2026-10-13 |
| [x] | `services/qr_service.py` — QR business logic isolated | 2026-10-13 |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `qr_display_screen.dart` — full-screen QR + blood group below | 2026-10-17 |
| [x] | QR generated offline using cached UID (`flutter_secure_storage`) | 2026-10-17 |
| [x] | QR rendered via `qr_flutter` package | 2026-10-17 |
| [x] | Download QR as PNG (`gallery_saver` or `image_gallery_saver`) | 2026-10-17 |
| [x] | Share QR via any app (`share_plus`) | 2026-10-17 |
| [x] | `qr_share_screen.dart` — download + share options | 2026-10-17 |
| [x] | `qr_preview_webview.dart` — in-app WebView of `goldenhr.pages.dev/p/{uid}` | 2026-10-17 |
| [x] | QR regenerate flow (confirmation dialog → invalidate → new QR) | 2026-10-17 |
| [x] | `qr_repository.dart` + `qr_provider.dart` | 2026-10-17 |

### Responder Web (React)
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | React Router configured for `/p/:uid`, `/p/notfound`, `/p/deactivated` | 2026-10-13 |
| [x] | `pages/EmergencyProfile.jsx` — fetches API and renders all sections | 2026-10-13 |
| [x] | Display: name, blood group, allergies, conditions, medications, contacts | 2026-10-13 |
| [x] | `pages/NotFound.jsx` — UID not found graceful error state | 2026-10-13 |
| [x] | `pages/Deactivated.jsx` — QR deactivated by patient | 2026-10-13 |
| [x] | `components/CriticalInfoCard.jsx` — blood group + allergies prominent | 2026-10-13 |
| [x] | `components/EmergencyContacts.jsx` — call + WhatsApp buttons | 2026-10-13 |
| [x] | `components/MedicationList.jsx` | 2026-10-13 |
| [x] | `components/AllergiesBadges.jsx` | 2026-10-13 |
| [x] | `components/LocationShareBtn.jsx` — responder GPS to family | 2026-10-13 |
| [x] | `components/EmergencyHelplineBar.jsx` — Indian emergency speed dials (108, 112, 100, 101) | 2026-10-17 |
| [x] | `components/ClinicalActionsBar.jsx` — hands-free voice readout (speech synthesis), triage summary copy, print chart, false alarm report | 2026-10-17 |
| [x] | Real-time scene GPS logging to backend scan event (`updateScanEvent`) | 2026-10-17 |
| [x] | Attending responder name/hospital live attachment to scan record | 2026-10-17 |
| [x] | Emergency dark mode / high-contrast theme toggle with persistence | 2026-10-17 |
| [x] | Sentry error monitoring integration (`@sentry/react`) | 2026-10-17 |
| [x] | `services/api.js` — axios/fetch wrapper with public scan update | 2026-10-17 |
| [x] | `styles/emergency.css` — full stylesheet with rich aesthetics & animations | 2026-10-17 |
| [x] | Responder name/hospital optional input field | 2026-10-13 |
| [x] | Medical disclaimer footer | 2026-10-13 |
| [x] | Print stylesheet (`@media print`) for clinical charts | 2026-10-17 |
| [x] | Page load < 2 seconds on 3G (no heavy libs, system fonts) | 2026-10-13 |
| [x] | `<noscript>` fallback text for critical info | 2026-10-13 |
| [x] | Deployed to Cloudflare Pages | 2026-10-18 |
| [x] | Native SPA routing active on Cloudflare (`wrangler.jsonc`) | 2026-10-18 |

---

## 🚨 Module 4 — Notifications & Alerting

### Backend — Celery & Task Queue
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `tasks/celery_app.py` — Celery app with Upstash Redis broker | 2026-10-13 |
| [x] | `tasks/notification_tasks.py` — `notify_emergency_contacts` task | 2026-10-13 |
| [x] | Celery worker starts correctly alongside FastAPI | 2026-10-13 |
| [x] | Task enqueued on every QR scan (with dedup check) | 2026-10-13 |
| [x] | Deduplication: same QR scanned < 5 min ago → skip notification | 2026-10-13 |
| [x] | Retry with exponential backoff (3 retries: 5s, 15s, 30s) | 2026-10-13 |
| [x] | In-process `BackgroundTasks` fallback if Celery/Redis is unavailable | 2026-10-17 |
| [x] | `entrypoint.sh` dual-process runner (Alembic + Celery + Uvicorn) | 2026-10-17 |
| [x] | `PATCH /qr/public/scan/{scan_event_id}` for live responder info & GPS | 2026-10-17 |

### Backend — Notification Channels
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `services/notification_service.py` — all channel logic isolated | 2026-10-13 |
| [x] | SMS via Fast2SMS — integrated and tested | 2026-10-13 |
| [x] | WhatsApp via Green-API — integrated | 2026-10-14 |
| [x] | Green-API instance linked & tested | 2026-10-14 |
| [x] | FCM push to patient device — integrated | 2026-10-13 |
| [x] | Email fallback via Resend.com — integrated | 2026-10-13 |
| [x] | Email fallback only triggers after SMS fails 3 retries | 2026-10-13 |

### Backend — Notification Endpoints
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/notifications.py` — router created | 2026-10-13 |
| [x] | `GET /notifications/history` — patient's scan + notification log | 2026-10-13 |
| [x] | `POST /notifications/false-alarm/{scan_id}` — mark as false alarm | 2026-10-13 |
| [x] | `POST /notifications/test` — send test SMS/WhatsApp to self | 2026-10-13 |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `firebase_messaging` package added to `pubspec.yaml` | 2026-10-17 |
| [x] | FCM `onBackgroundMessage` handler configured | 2026-10-17 |
| [x] | FCM token registered to backend on login | 2026-10-17 |
| [x] | Push notification received on QR scan — tested | 2026-10-17 |
| [x] | "Test Notification" button in settings screen | 2026-10-17 |

---

## 📂 Module 5 — Documents

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/documents.py` — router created | 2026-10-13 |
| [x] | `POST /documents/upload` — upload to Supabase Storage + save metadata | 2026-10-13 |
| [x] | `GET /documents` — list all documents for patient | 2026-10-13 |
| [x] | `DELETE /documents/{id}` — remove from storage + DB | 2026-10-13 |
| [x] | Documents never exposed on public responder endpoint | 2026-10-13 |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `documents_screen.dart` — list with name, type, date | 2026-10-17 |
| [x] | `upload_document_screen.dart` — bottom sheet: gallery / camera / files | 2026-10-17 |
| [x] | Document type selection (Prescription, Lab Report, Discharge, Insurance, Other) | 2026-10-17 |
| [x] | In-app PDF/image viewer | 2026-10-17 |
| [x] | `document_repository.dart` — API integration | 2026-10-17 |

---

## 📊 Module 6 — Scan History

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `api/v1/scan_events.py` — router created | 2026-10-13 |
| [x] | `GET /scan-events` — paginated scan events for patient | 2026-10-13 |
| [x] | `GET /scan-events/{id}` — single scan event detail | 2026-10-13 |
| [x] | `PATCH /scan-events/{id}/false-alarm` — flag as false alarm | 2026-10-13 |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `scan_history_screen.dart` — paginated list (time, location area, device) | 2026-10-17 |
| [x] | `scan_detail_screen.dart` — full GPS, responder info, notification status | 2026-10-17 |
| [x] | False alarm button (available 60s after scan) | 2026-10-17 |
| [x] | `scan_repository.dart` — API integration | 2026-10-17 |

---

## ⚙️ Module 7 — Settings

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `settings_screen.dart` — main settings screen | 2026-10-17 |
| [x] | `privacy_settings_screen.dart` — per-field privacy toggles | 2026-10-17 |
| [x] | QR activate / deactivate toggle in settings | 2026-10-17 |
| [x] | Logout button (clears tokens + calls backend) | 2026-10-17 |
| [x] | Delete Account (DPDPA right to erasure — hard delete all data) | 2026-10-17 |
| [x] | App version number displayed | 2026-10-17 |

---

## 🎨 UI Polish & Shared Components

| Status | Task | Completed On |
|--------|------|--------------|
| [x] | `shared/widgets/` — reusable UI components library | 2026-10-17 |
| [x] | App icon (512x512 PNG, no transparency) | 2026-10-17 |
| [x] | Splash screen animation (Lottie) | 2026-10-17 |
| [x] | Empty state illustrations (no scans, no documents) | 2026-10-17 |
| [x] | Loading states for all API calls | 2026-10-17 |
| [x] | Error handling — user-friendly error messages everywhere | 2026-10-17 |
| [x] | Smooth screen transitions (GoRouter) | 2026-10-17 |
| [x] | Micro-animations (profile completion, QR scan) | 2026-10-17 |
| [ ] | All screens tested on Android emulator | |
| [ ] | All screens tested on physical Android device | |

---

## 🔒 Security & Compliance

| Status | Task | Completed On |
|--------|------|--------------|
| [x] | No PII in QR URL (only opaque UID) | 2026-10-13 |
| [x] | Supabase RLS enabled and tested on all tables | 2026-10-17 |
| [x] | All `.env` files + `google-services.json` excluded from git | 2026-10-13 |
| [x] | Release keystore (`.jks`) generated and backed up securely | 2026-10-18 |
| [x] | DPDPA 2023 consent checkbox at registration with timestamp logged | 2026-10-13 |
| [x] | In-app account deletion implemented | 2026-10-13 |
| [x] | Medical disclaimer on responder page | 2026-10-13 |
| [x] | Sentry error monitoring — Flutter | 2026-10-19 |
| [x] | Sentry error monitoring — React Web | 2026-10-17 |
| [x] | Sentry error monitoring — Backend | 2026-10-13 |
| [x] | Better Uptime `/health` ping configured (10-min interval) | 2026-10-18 |

---

## 🚀 Deployment

| Status | Task | Completed On |
|--------|------|--------------|
| [x] | Backend deployed to Render.com | 2026-10-18 |
| [x] | `GET /health` returns 200 on Render | 2026-10-18 |
| [x] | Responder Web deployed to Cloudflare Pages | 2026-10-18 |
| [x] | Native SPA routing active on Cloudflare (`wrangler.jsonc`) | 2026-10-18 |
| [x] | Render free tier kept warm via Better Uptime | 2026-10-18 |
| [x] | Alembic migrations run successfully on production DB | 2026-10-18 |
| [x] | End-to-end test on production: Register → Profile → QR scan → Notification | 2026-10-18 |

---

## 📦 Play Store Submission

| Status | Task | Completed On |
|--------|------|--------------|
| [x] | App icon generated (512x512 PNG, no alpha) | 2026-10-17 |
| [ ] | Feature graphic created (1024x500 PNG) | |
| [ ] | Screenshots taken (min 2, phone form factor) | |
| [ ] | Short description written (80 chars max) | |
| [ ] | Full description written (4000 chars max) | |
| [ ] | Privacy Policy page live at a public URL | |
| [ ] | Terms of Service page live | |
| [x] | `android/app/build.gradle` signed with release keystore | 2026-10-18 |
| [ ] | Release App Bundle built: `flutter build appbundle --release` | |
| [ ] | `.aab` uploaded to Play Console (Internal Testing) | |
| [ ] | Content rating questionnaire completed | |
| [ ] | Data Safety form filled accurately | |
| [ ] | Internal testing build tested on real device | |
| [ ] | Promoted to Production track | |
| [ ] | Submitted for Google review | |

---

## 🔵 Post-Launch (Month 2+)

| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Profile photo upload | |
| [ ] | Medical document upload and management (full feature) | |
| [ ] | Multi-language support (Hindi, Telugu, Tamil) | |
| [ ] | Scan history with map view | |
| [ ] | NFC tag support | |
| [ ] | In-app notification centre | |
| [ ] | Profile completion nudge notifications | |
| [ ] | "Is your info up to date?" periodic reminders | |
| [ ] | PostHog analytics (Flutter + React) | |
| [ ] | Play Store review responses (first month) | |

---

## 📈 Progress Summary

| Phase | Total | Done | Remaining |
|-------|-------|------|-----------|
| Phase 0 — Setup & Accounts | 21 | 21 | 0 |
| Module 0 — Backend Foundation | 21 | 21 | 0 |
| Module 1 — Authentication | 22 | 22 | 0 |
| Module 2 — Patient Profile | 21 | 21 | 0 |
| Module 3 — QR Code | 41 | 41 | 0 |
| Module 4 — Notifications & Alerting | 25 | 25 | 0 |
| Module 5 — Documents | 10 | 10 | 0 |
| Module 6 — Scan History | 8 | 8 | 0 |
| Module 7 — Settings | 6 | 6 | 0 |
| UI Polish & Shared Components | 10 | 8 | 2 |
| Security & Compliance | 11 | 11 | 0 |
| Deployment | 7 | 7 | 0 |
| Play Store Submission | 15 | 2 | 13 |
| Post-Launch (Month 2+) | 10 | 0 | 10 |
| **TOTAL** | **228** | **203** | **25** |

---

*Last updated: 2026-10-18 | Target: Google Play Store launch by November 9, 2026*

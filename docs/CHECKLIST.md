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
| [ ] | Supabase project created | |
| [ ] | Supabase Phone Auth enabled | |
| [ ] | Supabase DB tables created (users, profiles, contacts, scan_events, documents) | |
| [ ] | Supabase Row Level Security (RLS) enabled on all tables | |
| [ ] | Firebase project created | |
| [ ] | Firebase Cloud Messaging (FCM) enabled | |
| [ ] | `google-services.json` downloaded | |
| [ ] | Cloudflare Pages project created & connected to GitHub | |
| [ ] | Render.com Web Service created & connected to GitHub | |
| [ ] | Upstash Redis DB created | |
| [ ] | Fast2SMS API key obtained | |
| [ ] | WhatsApp Cloud API access granted | |
| [ ] | WhatsApp `emergency_alert` template submitted for approval ⚠️ | |
| [ ] | Resend.com API key obtained | |
| [ ] | Sentry projects created (backend + web) | |
| [ ] | Better Uptime monitor set up (pings `/health` every 10 min) | |
| [ ] | Google Play Console account created ($25 fee) | |
| [ ] | All `.env` files filled with real credentials | |

---

## 🔧 Module 0 — Backend Foundation

### Database & Configuration
| Status | Task | Completed On |
|--------|------|--------------|
| [x] | FastAPI project scaffold (`main.py`, `config.py`) | 2026-10-11 |
| [x] | `requirements.txt` created | 2026-10-11 |
| [ ] | Python virtual environment set up | |
| [ ] | `config.py` — reads all env vars via `pydantic-settings` | |
| [ ] | `database.py` — SQLAlchemy async engine + session factory | |
| [ ] | Alembic initialized (`alembic init migrations`) | |

### SQLAlchemy Models
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `models/user.py` — User model | |
| [ ] | `models/profile.py` — Patient Profile model | |
| [ ] | `models/emergency_contact.py` — Emergency Contact model | |
| [ ] | `models/scan_event.py` — Scan Event model | |
| [ ] | `models/document.py` — Document model | |
| [ ] | Alembic initial migration created & tested | |
| [ ] | All tables created in Supabase DB | |

### Pydantic Schemas
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `schemas/auth.py` — OTP request/response schemas | |
| [ ] | `schemas/profile.py` — Profile create/update/response schemas | |
| [ ] | `schemas/scan_event.py` — Scan event schemas | |

### Middleware & Infrastructure
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `middleware/auth_middleware.py` — JWT validation middleware | |
| [ ] | `middleware/rate_limiter.py` — `slowapi` rate limiting | |
| [ ] | CORS configured for Cloudflare + localhost origins | |
| [ ] | Sentry SDK integrated in backend | |
| [ ] | `GET /health` endpoint returns `{"status": "healthy"}` | |

---

## 🔐 Module 1 — Authentication

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/auth.py` — router file created | |
| [ ] | `POST /auth/send-otp` — sends OTP via Supabase Auth | |
| [ ] | `POST /auth/verify-otp` — verifies OTP, returns JWT + refresh token | |
| [ ] | `POST /auth/refresh` — rotates refresh token → new access token | |
| [ ] | `POST /auth/logout` — revokes refresh token server-side | |
| [ ] | `DELETE /auth/delete-account` — hard deletes all user PII | |
| [ ] | JWT access token (15 min) + refresh token (30 days) working | |
| [ ] | `services/auth_service.py` — auth business logic isolated | |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | GoRouter configured with all routes | |
| [ ] | Riverpod setup with providers folder | |
| [ ] | `core/theme/` — app colors, typography, spacing tokens | |
| [ ] | `core/network/` — Dio HTTP client configured | |
| [ ] | Dio JWT interceptor (silent token refresh on 401) | |
| [ ] | `flutter_secure_storage` dependency added | |
| [ ] | `features/auth/data/auth_remote_source.dart` — API calls | |
| [ ] | `features/auth/data/auth_repository.dart` — repository layer | |
| [ ] | `features/auth/domain/auth_provider.dart` — Riverpod provider | |
| [ ] | `presentation/splash_screen.dart` — JWT check → route decision | |
| [ ] | `presentation/phone_input_screen.dart` — phone + country code | |
| [ ] | `presentation/otp_verify_screen.dart` — 6-digit OTP + 60s timer | |
| [ ] | Auto-login: app opens → valid token → skip login screen | |
| [ ] | Logout: clears tokens + calls backend logout | |

---

## 👤 Module 2 — Patient Profile

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/profile.py` — router file created | |
| [ ] | `GET /profile/me` — fetch full profile | |
| [ ] | `PUT /profile/me` — update all profile fields | |
| [ ] | `PATCH /profile/me/privacy` — update field visibility toggles | |
| [ ] | `PATCH /profile/me/status` — activate / deactivate QR | |
| [ ] | `GET /profile/contacts` — list emergency contacts | |
| [ ] | `POST /profile/contacts` — add emergency contact | |
| [ ] | `PUT /profile/contacts/{id}` — update contact | |
| [ ] | `DELETE /profile/contacts/{id}` — remove contact | |

### Flutter — Profile Wizard
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Wizard navigation (step indicator + next/back) | |
| [ ] | `step1_blood_group.dart` — blood group dropdown | |
| [ ] | `step2_allergies.dart` — multi-chip allergy input | |
| [ ] | `step3_conditions.dart` — chronic conditions multi-select + custom | |
| [ ] | `step4_medications.dart` — medication name + dosage + frequency | |
| [ ] | `step5_contacts.dart` — emergency contacts (up to 5) + WhatsApp toggle | |
| [ ] | Profile wizard data submitted to backend on completion | |

### Flutter — Profile Screens
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `profile_home_screen.dart` — summary card + completion score | |
| [ ] | `edit_profile_screen.dart` — full editable form | |
| [ ] | `privacy_settings_screen.dart` — per-field visibility toggles | |
| [ ] | `profile_repository.dart` — API integration | |
| [ ] | `profile_provider.dart` — Riverpod state provider | |

---

## 📱 Module 3 — QR Code

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/qr.py` — router file created | |
| [ ] | `POST /qr/generate` — create 8-char random UID, store mapping | |
| [ ] | `POST /qr/regenerate` — invalidate old UID, create new | |
| [ ] | `GET /qr/public/{uid}` — public endpoint (no auth) — returns safe fields | |
| [ ] | Scan event logged on every call to public endpoint | |
| [ ] | Rate limiting: 20 scans/hour per QR UID | |
| [ ] | `services/qr_service.py` — QR business logic isolated | |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `qr_display_screen.dart` — full-screen QR + blood group below | |
| [ ] | QR generated offline using cached UID (`flutter_secure_storage`) | |
| [ ] | QR rendered via `qr_flutter` package | |
| [ ] | Download QR as PNG (`gallery_saver` or `image_gallery_saver`) | |
| [ ] | Share QR via any app (`share_plus`) | |
| [ ] | `qr_share_screen.dart` — download + share options | |
| [ ] | `qr_preview_webview.dart` — in-app WebView of `goldenhr.pages.dev/p/{uid}` | |
| [ ] | QR regenerate flow (confirmation dialog → invalidate → new QR) | |
| [ ] | `qr_repository.dart` + `qr_provider.dart` | |

### Responder Web (React)
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | React Router configured for `/p/:uid`, `/p/notfound`, `/p/deactivated` | |
| [ ] | `pages/EmergencyProfile.jsx` — fetches API and renders all sections | |
| [ ] | Display: name, blood group, allergies, conditions, medications, contacts | |
| [ ] | `pages/NotFound.jsx` — UID not found graceful error state | |
| [ ] | `pages/Deactivated.jsx` — QR deactivated by patient | |
| [ ] | `components/CriticalInfoCard.jsx` — blood group + allergies prominent | |
| [ ] | `components/EmergencyContacts.jsx` — call + WhatsApp buttons | |
| [ ] | `components/MedicationList.jsx` | |
| [ ] | `components/AllergiesBadges.jsx` | |
| [ ] | `components/LocationShareBtn.jsx` — responder GPS to family | |
| [ ] | `services/api.js` — axios/fetch wrapper | |
| [ ] | `styles/emergency.css` — full stylesheet | |
| [ ] | Responder name/hospital optional input field | |
| [ ] | Medical disclaimer footer | |
| [ ] | Print stylesheet (`@media print`) | |
| [ ] | Page load < 2 seconds on 3G (no heavy libs, system fonts) | |
| [ ] | `<noscript>` fallback text for critical info | |
| [ ] | Deployed to Cloudflare Pages | |
| [ ] | `public/_redirects` file: `/* /index.html 200` | |

---

## 🚨 Module 4 — Notifications & Alerting

### Backend — Celery & Task Queue
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `tasks/celery_app.py` — Celery app with Upstash Redis broker | |
| [ ] | `tasks/notification_tasks.py` — `notify_emergency_contacts` task | |
| [ ] | Celery worker starts correctly alongside FastAPI | |
| [ ] | Task enqueued on every QR scan (with dedup check) | |
| [ ] | Deduplication: same QR scanned < 5 min ago → skip notification | |
| [ ] | Retry with exponential backoff (3 retries: 5s, 15s, 30s) | |

### Backend — Notification Channels
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `services/notification_service.py` — all channel logic isolated | |
| [ ] | SMS via Fast2SMS — integrated and tested | |
| [ ] | WhatsApp via WhatsApp Cloud API — integrated | |
| [ ] | WhatsApp `emergency_alert` template approved & tested | |
| [ ] | FCM push to patient device — integrated | |
| [ ] | Email fallback via Resend.com — integrated | |
| [ ] | Email fallback only triggers after SMS fails 3 retries | |

### Backend — Notification Endpoints
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/notifications.py` — router created | |
| [ ] | `GET /notifications/history` — patient's scan + notification log | |
| [ ] | `POST /notifications/false-alarm/{scan_id}` — mark as false alarm | |
| [ ] | `POST /notifications/test` — send test SMS/WhatsApp to self | |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `firebase_messaging` package added to `pubspec.yaml` | |
| [ ] | FCM `onBackgroundMessage` handler configured | |
| [ ] | FCM token registered to backend on login | |
| [ ] | Push notification received on QR scan — tested | |
| [ ] | "Test Notification" button in settings screen | |

---

## 📂 Module 5 — Documents

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/documents.py` — router created | |
| [ ] | `POST /documents/upload` — upload to Supabase Storage + save metadata | |
| [ ] | `GET /documents` — list all documents for patient | |
| [ ] | `DELETE /documents/{id}` — remove from storage + DB | |
| [ ] | Documents never exposed on public responder endpoint | |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `documents_screen.dart` — list with name, type, date | |
| [ ] | `upload_document_screen.dart` — bottom sheet: gallery / camera / files | |
| [ ] | Document type selection (Prescription, Lab Report, Discharge, Insurance, Other) | |
| [ ] | In-app PDF/image viewer | |
| [ ] | `document_repository.dart` — API integration | |

---

## 📊 Module 6 — Scan History

### Backend
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `api/v1/scan_events.py` — router created | |
| [ ] | `GET /scan-events` — paginated scan events for patient | |
| [ ] | `GET /scan-events/{id}` — single scan event detail | |
| [ ] | `PATCH /scan-events/{id}/false-alarm` — flag as false alarm | |

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `scan_history_screen.dart` — paginated list (time, location area, device) | |
| [ ] | `scan_detail_screen.dart` — full GPS, responder info, notification status | |
| [ ] | False alarm button (available 60s after scan) | |
| [ ] | `scan_repository.dart` — API integration | |

---

## ⚙️ Module 7 — Settings

### Flutter
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `settings_screen.dart` — main settings screen | |
| [ ] | `privacy_settings_screen.dart` — per-field privacy toggles | |
| [ ] | QR activate / deactivate toggle in settings | |
| [ ] | Logout button (clears tokens + calls backend) | |
| [ ] | Delete Account (DPDPA right to erasure — hard delete all data) | |
| [ ] | App version number displayed | |

---

## 🎨 UI Polish & Shared Components

| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `shared/widgets/` — reusable UI components library | |
| [ ] | App icon (512x512 PNG, no transparency) | |
| [ ] | Splash screen animation (Lottie) | |
| [ ] | Empty state illustrations (no scans, no documents) | |
| [ ] | Loading states for all API calls | |
| [ ] | Error handling — user-friendly error messages everywhere | |
| [ ] | Smooth screen transitions (GoRouter) | |
| [ ] | Micro-animations (profile completion, QR scan) | |
| [ ] | All screens tested on Android emulator | |
| [ ] | All screens tested on physical Android device | |

---

## 🔒 Security & Compliance

| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | No PII in QR URL (only opaque UID) | |
| [ ] | Supabase RLS enabled and tested on all tables | |
| [ ] | All `.env` files + `google-services.json` excluded from git | |
| [ ] | Release keystore (`.jks`) generated and backed up securely | |
| [ ] | DPDPA 2023 consent checkbox at registration with timestamp logged | |
| [ ] | In-app account deletion implemented | |
| [ ] | Medical disclaimer on responder page | |
| [ ] | Sentry error monitoring — Flutter | |
| [ ] | Sentry error monitoring — React Web | |
| [ ] | Sentry error monitoring — Backend | |
| [ ] | Better Uptime `/health` ping configured (10-min interval) | |

---

## 🚀 Deployment

| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend deployed to Render.com | |
| [ ] | `GET /health` returns 200 on Render | |
| [ ] | Responder Web deployed to Cloudflare Pages | |
| [ ] | `_redirects` file active on Cloudflare | |
| [ ] | Render free tier kept warm via Better Uptime | |
| [ ] | Alembic migrations run successfully on production DB | |
| [ ] | End-to-end test on production: Register → Profile → QR scan → Notification | |

---

## 📦 Play Store Submission

| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | App icon generated (512x512 PNG, no alpha) | |
| [ ] | Feature graphic created (1024x500 PNG) | |
| [ ] | Screenshots taken (min 2, phone form factor) | |
| [ ] | Short description written (80 chars max) | |
| [ ] | Full description written (4000 chars max) | |
| [ ] | Privacy Policy page live at a public URL | |
| [ ] | Terms of Service page live | |
| [ ] | `android/app/build.gradle` signed with release keystore | |
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
| Phase 0 — Setup & Accounts | 21 | 3 | 18 |
| Module 0 — Backend Foundation | 16 | 2 | 14 |
| Module 1 — Authentication | 20 | 0 | 20 |
| Module 2 — Patient Profile | 19 | 0 | 19 |
| Module 3 — QR Code | 24 | 0 | 24 |
| Module 4 — Notifications | 21 | 0 | 21 |
| Module 5 — Documents | 9 | 0 | 9 |
| Module 6 — Scan History | 8 | 0 | 8 |
| Module 7 — Settings | 6 | 0 | 6 |
| UI Polish | 10 | 0 | 10 |
| Security & Compliance | 11 | 0 | 11 |
| Deployment | 7 | 0 | 7 |
| Play Store | 15 | 0 | 15 |
| Post-Launch | 10 | 0 | 10 |
| **TOTAL** | **197** | **5** | **192** |

---

*Last updated: 2026-10-13 | Target: Google Play Store launch by November 9, 2026*

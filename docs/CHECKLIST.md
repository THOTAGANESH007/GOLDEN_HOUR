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
| [ ] | Supabase Phone Auth enabled | |
| [x] | Supabase DB tables created (users, profiles, contacts, scan_events, documents) | 2026-10-13 |
| [ ] | Supabase Row Level Security (RLS) enabled on all tables | |
| [x] | Firebase project created | 2026-10-14 |
| [x] | Firebase Cloud Messaging (FCM) enabled | 2026-10-14 |
| [x] | `google-services.json` downloaded | 2026-10-14 |
| [ ] | Cloudflare Pages project created & connected to GitHub | |
| [ ] | Render.com Web Service created & connected to GitHub | |
| [x] | Upstash Redis DB created | 2026-10-14 |
| [x] | Fast2SMS API key obtained | 2026-10-14 |
| [x] | Green-API WhatsApp account & instance created | 2026-10-14 |
| [x] | Green-API linked via WhatsApp QR code | 2026-10-14 |
| [x] | Resend.com API key obtained | 2026-10-14 |
| [x] | Sentry projects created (backend + web) | 2026-10-14 |
| [ ] | Better Uptime monitor set up (pings `/health` every 10 min) | |
| [ ] | Google Play Console account created ($25 fee) | |
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
| [x] | `services/api.js` — axios/fetch wrapper | 2026-10-13 |
| [x] | `styles/emergency.css` — full stylesheet | 2026-10-13 |
| [x] | Responder name/hospital optional input field | 2026-10-13 |
| [x] | Medical disclaimer footer | 2026-10-13 |
| [x] | Print stylesheet (`@media print`) | 2026-10-13 |
| [x] | Page load < 2 seconds on 3G (no heavy libs, system fonts) | 2026-10-13 |
| [x] | `<noscript>` fallback text for critical info | 2026-10-13 |
| [ ] | Deployed to Cloudflare Pages | |
| [x] | `public/_redirects` file: `/* /index.html 200` | 2026-10-13 |

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
| [x] | `api/v1/documents.py` — router created | 2026-10-13 |
| [x] | `POST /documents/upload` — upload to Supabase Storage + save metadata | 2026-10-13 |
| [x] | `GET /documents` — list all documents for patient | 2026-10-13 |
| [x] | `DELETE /documents/{id}` — remove from storage + DB | 2026-10-13 |
| [x] | Documents never exposed on public responder endpoint | 2026-10-13 |

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
| [x] | `api/v1/scan_events.py` — router created | 2026-10-13 |
| [x] | `GET /scan-events` — paginated scan events for patient | 2026-10-13 |
| [x] | `GET /scan-events/{id}` — single scan event detail | 2026-10-13 |
| [x] | `PATCH /scan-events/{id}/false-alarm` — flag as false alarm | 2026-10-13 |

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
| [x] | No PII in QR URL (only opaque UID) | 2026-10-13 |
| [ ] | Supabase RLS enabled and tested on all tables | |
| [x] | All `.env` files + `google-services.json` excluded from git | 2026-10-13 |
| [ ] | Release keystore (`.jks`) generated and backed up securely | |
| [x] | DPDPA 2023 consent checkbox at registration with timestamp logged | 2026-10-13 |
| [x] | In-app account deletion implemented | 2026-10-13 |
| [x] | Medical disclaimer on responder page | 2026-10-13 |
| [ ] | Sentry error monitoring — Flutter | |
| [ ] | Sentry error monitoring — React Web | |
| [x] | Sentry error monitoring — Backend | 2026-10-13 |
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
| Phase 0 — Setup & Accounts | 21 | 15 | 6 |
| Module 0 — Backend Foundation | 21 | 21 | 0 |
| Module 1 — Authentication | 22 | 8 | 14 |
| Module 2 — Patient Profile | 21 | 9 | 12 |
| Module 3 — QR Code | 35 | 25 | 10 |
| Module 4 — Notifications | 22 | 17 | 5 |
| Module 5 — Documents | 10 | 5 | 5 |
| Module 6 — Scan History | 8 | 4 | 4 |
| Module 7 — Settings | 6 | 0 | 6 |
| UI Polish | 10 | 0 | 10 |
| Security & Compliance | 11 | 6 | 5 |
| Deployment | 7 | 0 | 7 |
| Play Store | 15 | 0 | 15 |
| Post-Launch | 10 | 0 | 10 |
| **TOTAL** | **199** | **110** | **89** |

---

*Last updated: 2026-10-13 | Target: Google Play Store launch by November 9, 2026*

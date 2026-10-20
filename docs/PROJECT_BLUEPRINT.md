# 🏥 Golden Hour — Project Blueprint

> **Universal Medical Emergency QR Code System**  
> Version: 2.0 | Date: October 2026 | Status: Active Development  
> **Target: Build & Ship to Google Play Store within 1 Month**

---

## Table of Contents

1. [Tech Stack](#1-tech-stack)
2. [Project Structure](#2-project-structure)
3. [User Roles](#3-user-roles)
4. [Complete Feature List](#4-complete-feature-list)
5. [Module-wise Feature Breakdown](#5-module-wise-feature-breakdown)
6. [Accounts to Create Before Setup](#6-accounts-to-create-before-setup)
7. [Environment Variables](#7-environment-variables)
8. [4-Week Build Roadmap](#8-4-week-build-roadmap)
9. [Google Play Store — Publishing Guide](#9-google-play-store--publishing-guide)
10. [Things You Might Have Missed](#10-things-you-might-have-missed)

---

## 1. Tech Stack

### 📱 Mobile App — Patient (Flutter)

| Layer               | Tool / Package                  | Purpose                                      |
| ------------------- | ------------------------------- | -------------------------------------------- |
| Framework           | **Flutter (Dart)**              | Cross-platform Android app (+ iOS ready)     |
| State Management    | **Riverpod**                    | Scalable, reactive state management          |
| Navigation          | **GoRouter**                    | Declarative deep-link routing                |
| QR Generation       | `qr_flutter`                    | Render QR code from UID                      |
| HTTP Client         | **Dio**                         | API calls with interceptors                  |
| Local Secure Store  | `flutter_secure_storage`        | Store JWT tokens securely on device          |
| Push Notifications  | `firebase_messaging`            | Receive scan alerts on patient's phone       |
| Image Picker        | `image_picker`                  | Upload profile photo / medical documents     |
| PDF Generation      | `pdf` + `printing`              | Generate printable medical ID card           |
| Supabase Client     | `supabase_flutter`              | Auth, DB, Storage integration                |
| Connectivity        | `connectivity_plus`             | Detect offline state                         |
| In-App WebView      | `webview_flutter`               | Preview responder page inside app            |
| Share               | `share_plus`                    | Share QR code / card                         |
| Animations          | `lottie`                        | Onboarding and loading animations            |
| Local Notifications | `flutter_local_notifications`   | Show local alerts for scan events            |

---

### 🌐 Responder Web App (React)

| Layer            | Tool                        | Purpose                                          |
| ---------------- | --------------------------- | ------------------------------------------------ |
| Framework        | **React (Vite)**            | Fast, lightweight SPA — no SSR overhead needed   |
| Styling          | **Vanilla CSS**             | Ultra-minimal bundle; fast on 2G networks        |
| HTTP Client      | **Axios**                   | Fetch patient data from backend API              |
| Routing          | **React Router v6**         | Handle `/p/:uid` dynamic route                   |
| Hosting          | **Cloudflare Pages**        | Free global CDN, custom domain support           |
| Icons            | **Lucide React**            | Clean, lightweight icon set                      |
| Build Tool       | **Vite**                    | Blazing fast builds, small bundle size           |

> **Why separate React web page?**  
> When a first responder scans the QR code, it opens in their phone's default browser — they do NOT have our Flutter app installed. The React web page is unavoidable and must load in < 2 seconds on 3G. Flutter WebView inside the patient app is used only for previewing this page from within the app.

---

### ⚙️ Backend API (FastAPI)

| Layer            | Tool                        | Purpose                                          |
| ---------------- | --------------------------- | ------------------------------------------------ |
| Framework        | **FastAPI (Python 3.12)**   | High-performance async REST API                  |
| ORM              | **SQLAlchemy + Alembic**    | DB models and schema migrations                  |
| Validation       | **Pydantic v2**             | Request/response schema validation               |
| Auth             | **Firebase Auth + JWT**     | 1-Tap Google Sign-In, token verification, JWT    |
| Task Queue       | **Celery**                  | Async background emergency dispatching           |
| Message Broker   | **Local Redis (Docker)**    | In-memory broker (`golden-hour-redis`), < 0.5ms  |
| Hosting          | **Oracle Cloud (OCI)**      | Always-Free `VM.Standard.E2.1.Micro` (Ubuntu)    |
| SSL & Domain     | **Caddy + DuckDNS**         | `https://goldenhour-backend.duckdns.org` (TLS)   |
| CORS             | **FastAPI CORSMiddleware**  | Allow Flutter app, Cloudflare Pages, localhost   |
| Rate Limiting    | **slowapi**                 | Protect QR scan and auth endpoints from abuse    |
| Monitoring       | **Sentry**                  | Real-time exception & error tracking             |

---

### 🗄️ Database & Storage (Local Production Stack)

| Service                      | Usage                                                  |
| ---------------------------- | ------------------------------------------------------ |
| **PostgreSQL 16 (Docker)**   | Primary database on persistent SSD volume (`~/postgres_data`) |
| **Database Container**       | `golden-hour-db`, private port 5432 on `golden-net`     |
| **Supabase Storage**         | Medical documents, profile photos                      |
| **Row Level Security (RLS)** | Patients can only read/write their own records         |

---

### 🔔 Notifications (100% Free Production Stack)

| Channel       | Tool                   | Free Limit                          |
| ------------- | ---------------------- | ----------------------------------- |
| Emergency Push (Patient & Contacts) | **Firebase FCM** | **Unlimited (100% Free Forever)** — High priority with maps link |
| WhatsApp      | **Green-API**          | Instant emergency alert dispatch    |
| SMS           | **Fast2SMS**           | ₹50 signup wallet (India)           |
| Email Fallback| **Resend.com**         | 3,000 emails/month free             |

---

### 🔧 DevOps & Tooling (All Free)

| Component       | Tool                                               |
| --------------- | -------------------------------------------------- |
| Version Control | **GitHub** (monorepo)                              |
| Web Hosting     | **Cloudflare Pages & Workers** (`goldenhr.pages.dev`) |
| VM Host         | **Oracle Cloud Always Free** (`129.225.91.215`)     |
| Dynamic DNS     | **DuckDNS** (`goldenhour-backend.duckdns.org`)      |
| Reverse Proxy   | **Caddy v2** (Automated Let's Encrypt TLS 1.3)     |
| Monitoring      | **Sentry** (Mobile + Backend + Web)                |
| API Testing     | **Thunder Client / Postman / cURL**                |
| DNS + CDN       | **Cloudflare** (Free Global CDN)                   |

---

## 2. Project Structure

```
golden-hour/                          ← Monorepo root
│
├── apps/
│   ├── mobile/                       ← Flutter patient app (Android-first)
│   │   ├── android/
│   │   │   └── app/
│   │   │       ├── build.gradle      ← App signing config for Play Store
│   │   │       └── src/main/
│   │   │           └── AndroidManifest.xml
│   │   ├── ios/                      ← iOS ready (not priority for Month 1)
│   │   ├── lib/
│   │   │   ├── main.dart             ← Single entry point (no flavors)
│   │   │   ├── app/
│   │   │   │   ├── app.dart          ← App root widget
│   │   │   │   └── router.dart       ← GoRouter config
│   │   │   │
│   │   │   ├── core/
│   │   │   │   ├── constants/
│   │   │   │   │   └── app_constants.dart  ← API URL, Supabase keys
│   │   │   │   ├── theme/            ← Colors, typography, spacing
│   │   │   │   ├── utils/            ← Helper functions
│   │   │   │   ├── network/          ← Dio client + interceptors
│   │   │   │   └── errors/           ← Error handling models
│   │   │   │
│   │   │   ├── features/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── data/
│   │   │   │   │   │   ├── auth_repository.dart
│   │   │   │   │   │   └── auth_remote_source.dart
│   │   │   │   │   ├── domain/
│   │   │   │   │   │   └── auth_provider.dart
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── splash_screen.dart
│   │   │   │   │       ├── phone_input_screen.dart
│   │   │   │   │       └── otp_verify_screen.dart
│   │   │   │   │
│   │   │   │   ├── profile/
│   │   │   │   │   ├── data/
│   │   │   │   │   │   └── profile_repository.dart
│   │   │   │   │   ├── domain/
│   │   │   │   │   │   └── profile_provider.dart
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── profile_wizard/
│   │   │   │   │       │   ├── step1_blood_group.dart
│   │   │   │   │       │   ├── step2_allergies.dart
│   │   │   │   │       │   ├── step3_conditions.dart
│   │   │   │   │       │   ├── step4_medications.dart
│   │   │   │   │       │   └── step5_contacts.dart
│   │   │   │   │       ├── edit_profile_screen.dart
│   │   │   │   │       └── profile_home_screen.dart
│   │   │   │   │
│   │   │   │   ├── qr_code/
│   │   │   │   │   ├── data/
│   │   │   │   │   │   └── qr_repository.dart
│   │   │   │   │   ├── domain/
│   │   │   │   │   │   └── qr_provider.dart
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── qr_display_screen.dart
│   │   │   │   │       ├── qr_share_screen.dart
│   │   │   │   │       └── qr_preview_webview.dart
│   │   │   │   │
│   │   │   │   ├── scan_history/
│   │   │   │   │   ├── data/
│   │   │   │   │   │   └── scan_repository.dart
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── scan_history_screen.dart
│   │   │   │   │       └── scan_detail_screen.dart
│   │   │   │   │
│   │   │   │   ├── documents/
│   │   │   │   │   ├── data/
│   │   │   │   │   │   └── document_repository.dart
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── documents_screen.dart
│   │   │   │   │       └── upload_document_screen.dart
│   │   │   │   │
│   │   │   │   └── settings/
│   │   │   │       └── presentation/
│   │   │   │           ├── settings_screen.dart
│   │   │   │           └── privacy_settings_screen.dart
│   │   │   │
│   │   │   └── shared/
│   │   │       ├── widgets/          ← Reusable UI components
│   │   │       └── providers/        ← Global Riverpod providers
│   │   │
│   │   ├── assets/
│   │   │   ├── images/
│   │   │   │   ├── logo.png
│   │   │   │   └── app_icon.png      ← Play Store icon (512x512 PNG)
│   │   │   ├── animations/           ← Lottie JSON files
│   │   │   └── fonts/
│   │   ├── pubspec.yaml
│   │   └── .env                      ← Single .env file (all keys here)
│   │
│   ├── responder-web/                ← React Vite web app
│   │   ├── public/
│   │   │   └── _redirects            ← "/* /index.html 200" for Cloudflare
│   │   ├── src/
│   │   │   ├── main.jsx
│   │   │   ├── App.jsx
│   │   │   ├── pages/
│   │   │   │   ├── EmergencyProfile.jsx   ← /p/:uid — main responder view
│   │   │   │   ├── NotFound.jsx           ← QR not found
│   │   │   │   └── Deactivated.jsx        ← QR is inactive
│   │   │   ├── components/
│   │   │   │   ├── CriticalInfoCard.jsx
│   │   │   │   ├── EmergencyContacts.jsx
│   │   │   │   ├── MedicationList.jsx
│   │   │   │   ├── AllergiesBadges.jsx
│   │   │   │   └── LocationShareBtn.jsx
│   │   │   ├── services/
│   │   │   │   └── api.js
│   │   │   └── styles/
│   │   │       └── emergency.css
│   │   ├── index.html
│   │   ├── vite.config.js
│   │   ├── .env                      ← Single .env (VITE_API_BASE_URL)
│   │   └── package.json
│   │
│   └── admin-web/                    ← (Future) Hospital admin portal
│       └── ...
│
├── backend/                          ← FastAPI backend
│   ├── app/
│   │   ├── main.py                   ← FastAPI app entry + router registration
│   │   ├── config.py                 ← Reads from single .env file
│   │   ├── database.py               ← SQLAlchemy engine + session
│   │   │
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── auth.py           ← OTP, login, refresh, logout
│   │   │       ├── profile.py        ← CRUD patient profile
│   │   │       ├── qr.py             ← QR generation + public scan endpoint
│   │   │       ├── notifications.py  ← History, false alarm, test send
│   │   │       ├── documents.py      ← Upload / list / delete
│   │   │       └── scan_events.py    ← Scan log retrieval
│   │   │
│   │   ├── models/                   ← SQLAlchemy DB models
│   │   │   ├── user.py
│   │   │   ├── profile.py
│   │   │   ├── emergency_contact.py
│   │   │   ├── scan_event.py
│   │   │   └── document.py
│   │   │
│   │   ├── schemas/                  ← Pydantic request/response schemas
│   │   │   ├── profile.py
│   │   │   ├── auth.py
│   │   │   └── scan_event.py
│   │   │
│   │   ├── services/                 ← Business logic
│   │   │   ├── notification_service.py
│   │   │   ├── qr_service.py
│   │   │   └── auth_service.py
│   │   │
│   │   ├── tasks/                    ← Celery async tasks
│   │   │   ├── celery_app.py
│   │   │   └── notification_tasks.py
│   │   │
│   │   └── middleware/
│   │       ├── auth_middleware.py
│   │       └── rate_limiter.py
│   │
│   ├── migrations/                   ← Alembic migration files
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env                          ← Single .env file (all backend keys)
│
├── docs/
│   ├── PROJECT_BLUEPRINT.md          ← This file
│   ├── BRD.md                        ← Business requirements document
│   ├── API.md                        ← API endpoint reference
│   └── DB_SCHEMA.md                  ← Database schema
│
├── .github/
│   └── workflows/
│       ├── backend-deploy.yml        ← Auto deploy backend to Render on push
│       └── web-deploy.yml            ← Auto deploy React app to Cloudflare
│
├── .gitignore                        ← Must include all .env files!
└── README.md
```

---

## 3. User Roles

### Role 1 — 🤒 Patient (Primary App User)
- **Access**: Flutter Android app (authenticated via OTP)
- **Can Do**:
  - Register / login via phone OTP
  - Create and edit full medical profile (5-step wizard)
  - Generate, download, and share their unique QR code
  - Print medical ID card (PDF, credit-card format)
  - Add/manage up to 5 emergency contacts
  - Upload medical documents (prescriptions, lab reports)
  - View full scan history (when, where, by whom)
  - Toggle privacy settings per field
  - Activate / deactivate QR code (Ghost Mode)
  - Mark a scan as false alarm
  - Preview their responder page via in-app WebView

---

### Role 2 — 🚑 First Responder (Anonymous Web User)
- **Access**: React web page opened by scanning QR — **No app install, No login, No friction**
- **Can Do**:
  - View critical medical data (blood group, allergies, conditions, medications)
  - One-tap call / WhatsApp emergency contacts
  - Share their GPS location with the patient's family
  - Optionally enter name/hospital (shown in patient notification)
- **Cannot Do**:
  - Edit any patient data
  - View fields the patient has privacy-toggled off
  - Access any other patient's profile

---

### Role 3 — 👨‍👩‍👧 Emergency Contact (Passive — No App Needed)
- **Access**: SMS + WhatsApp notifications only
- **Receives**:
  - Instant alert on QR scan: patient name, time, GPS link of responder
  - Responder's name/hospital if self-entered
- **Can Do**: Nothing in-system — receives notifications only

---

### Role 4 — 🛡️ Super Admin (Internal Team — Future)
- **Access**: Backend admin panel (separate, secured route)
- **Can Do**:
  - View all users, scan events, system health
  - Manage abuse reports and flagged accounts
  - View audit logs

---

## 4. Complete Feature List

### ✅ Month 1 — Build & Ship to Play Store

**Core App (Flutter)**
- [ ] Phone OTP registration and login (Supabase Auth)
- [ ] 5-step medical profile wizard
- [ ] Edit profile (any field, any time)
- [ ] Field-level privacy toggles
- [ ] QR code generation (unique UID per user)
- [ ] QR code display (full screen)
- [ ] QR code download as PNG
- [ ] QR code share via any app
- [ ] Printable medical ID card (PDF export)
- [ ] In-app WebView preview of responder page
- [ ] QR activate / deactivate toggle
- [ ] Basic scan history screen
- [ ] False alarm dismissal
- [ ] Offline QR display (cached locally)
- [ ] FCM push notification on scan

**Responder Web (React)**
- [ ] Emergency profile page `/p/:uid`
- [ ] Display: name, blood group, allergies, conditions, medications, contacts
- [ ] One-tap call button for each emergency contact
- [ ] One-tap WhatsApp button for each emergency contact
- [ ] Location share button (responder GPS → sent to family)
- [ ] Responder name/hospital optional input
- [ ] Page load < 2 seconds on 3G
- [ ] Graceful error states (inactive QR, not found)
- [ ] Medical disclaimer footer
- [ ] Print stylesheet (`@media print`)

**Backend (FastAPI)**
- [ ] OTP auth flow (send + verify + JWT)
- [ ] Full profile CRUD API
- [ ] QR UID generation + public scan endpoint
- [ ] Scan event logging (timestamp, GPS, device)
- [ ] Celery notification dispatch (SMS + WhatsApp + FCM)
- [ ] SMS via Fast2SMS
- [ ] WhatsApp via WhatsApp Cloud API
- [ ] Email fallback via Resend.com
- [ ] Rate limiting on scan endpoint (20 scans/hr per QR)
- [ ] Notification deduplication (5-min window)
- [ ] Document upload/list/delete API
- [ ] False alarm endpoint
- [ ] `/health` endpoint (for uptime ping)

**Google Play Store**
- [ ] App icon (512x512 PNG, no alpha)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (min 2, phone form factor)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Privacy Policy URL (live webpage)
- [ ] App signed with release keystore
- [ ] App Bundle (`.aab`) generated
- [ ] Play Console account setup ($25 one-time fee)
- [ ] App submitted for review

### 🔵 Post-Launch (Month 2+)
- [ ] Medical document upload and management
- [ ] Profile photo upload
- [ ] Multi-language support (Hindi, Telugu, Tamil)
- [ ] Scan history with map view
- [ ] NFC tag support
- [ ] In-app notification center
- [ ] Profile completion nudge notifications
- [ ] "Is your info up to date?" periodic reminders

---

## 5. Module-wise Feature Breakdown

---

### Module 1 — 🔐 Authentication

**Flutter Screens**
| Screen | Description |
|---|---|
| Splash Screen | Check JWT validity → route to Home or Login |
| Phone Input | Enter mobile number with country code (+91) |
| OTP Verify | 6-digit OTP input with 60s resend timer |

**Logic**
| Feature | Description |
|---|---|
| OTP Login | Phone number → OTP → JWT access + refresh token issued |
| JWT Storage | Access token (15 min) + refresh token (30 days) in `flutter_secure_storage` |
| Auto Login | On app open, validate stored token → skip login if valid |
| Token Refresh | Dio interceptor auto-refreshes expired access token silently |
| Logout | Clear local tokens + call `/auth/logout` to revoke server-side |
| Account Deletion | Hard delete all PII (DPDPA right to erasure) |

**Backend Endpoints**
| Endpoint | Method | Auth Required | Description |
|---|---|---|---|
| `/auth/send-otp` | POST | ❌ | Send OTP to phone via Supabase Auth |
| `/auth/verify-otp` | POST | ❌ | Verify OTP → return JWT + refresh token |
| `/auth/refresh` | POST | ❌ | Rotate refresh token → new access token |
| `/auth/logout` | POST | ✅ | Revoke refresh token server-side |
| `/auth/delete-account` | DELETE | ✅ | Hard delete all user data |

---

### Module 2 — 👤 Patient Profile

**Flutter Screens**
| Screen | Description |
|---|---|
| Profile Wizard Step 1 | Blood group selection (dropdown) |
| Profile Wizard Step 2 | Allergies (add multiple, chip-style) |
| Profile Wizard Step 3 | Chronic conditions (multi-select + custom) |
| Profile Wizard Step 4 | Current medications (name + dosage + frequency) |
| Profile Wizard Step 5 | Emergency contacts (up to 5 with WhatsApp toggle) |
| Profile Home | Summary card + completion score + edit button |
| Edit Profile | Full form to update any field |
| Privacy Settings | Per-field toggle: name, DOB, photo, conditions, meds |

**Data Fields**
```
Personal:       Full Name, Date of Birth, Gender
Critical:       Blood Group, Allergies[], Chronic Conditions[]
Medications:    [{ name, dosage, frequency }] — multiple entries
Medical:        Past Surgeries[], Implants[], Organ Donor (bool)
Contacts:       [{ name, relation, phone (E.164), whatsapp_enabled }] — max 5
Doctor:         Primary Physician Name + Phone
Privacy:        show_name, show_dob, show_photo, is_active (all bool)
```

**Backend Endpoints**
| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/profile/me` | GET | ✅ | Fetch authenticated patient's full profile |
| `/profile/me` | PUT | ✅ | Update profile fields |
| `/profile/me/privacy` | PATCH | ✅ | Update field-visibility toggles |
| `/profile/me/status` | PATCH | ✅ | Activate / deactivate QR |
| `/profile/contacts` | GET | ✅ | List emergency contacts |
| `/profile/contacts` | POST | ✅ | Add emergency contact |
| `/profile/contacts/{id}` | PUT | ✅ | Update contact |
| `/profile/contacts/{id}` | DELETE | ✅ | Remove contact |

---

### Module 3 — 📱 QR Code

**Flutter Screens**
| Screen | Description |
|---|---|
| QR Display | Full-screen QR code with blood group shown below |
| QR Actions | Download PNG / Share / Print PDF / Preview / Regenerate |
| Responder Preview | WebView of `goldenhr.pages.dev/p/{uid}` |

**QR Logic**
| Feature | Description |
|---|---|
| UID Format | Random 8-char alphanumeric (e.g., `X7K2M9QP`) — not sequential |
| QR URL | `https://goldenhr.pages.dev/p/{uid}` |
| Offline Fallback | UID cached locally; QR rendered offline via `qr_flutter` |
| Regenerate | Invalidates old UID → new one created; old URL returns 404 |

**Backend Endpoints**
| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/qr/generate` | POST | ✅ | Create UID, store mapping to patient |
| `/qr/regenerate` | POST | ✅ | Invalidate old UID, create new |
| `/qr/public/{uid}` | GET | ❌ | **Public** — return safe fields + trigger notification task |

**Responder Web Pages**
| Route | Component | Description |
|---|---|---|
| `/p/:uid` | `EmergencyProfile.jsx` | Main emergency view |
| `/p/:uid` (inactive) | `Deactivated.jsx` | Profile deactivated by patient |
| `*` | `NotFound.jsx` | UID not found or deleted |

---

### Module 4 — 🚨 Notifications & Alerting

**Full Notification Flow**
```
1. Responder opens https://goldenhr.pages.dev/p/{uid}
2. React app fires: GET /qr/public/{uid}
3. Backend:
   a. Verifies UID exists and profile is active
   b. Returns patient profile data to React app
   c. Logs ScanEvent (timestamp, device UA, GPS if provided)
   d. Checks deduplication: same UID scanned in last 5 min? → skip
   e. Enqueues Celery task: notify_emergency_contacts
4. Celery worker runs notify_emergency_contacts:
   a. Fetches all contacts with notify_on_scan = true
   b. For each contact:
      - Sends SMS via Fast2SMS
      - Sends WhatsApp via WhatsApp Cloud API (if whatsapp_enabled)
   c. Sends FCM push to patient's registered device token
   d. Sends email fallback via Resend (if SMS fails after 3 retries)
5. All notifications delivered within < 5 seconds
```

**Notification Templates**

SMS:
```
EMERGENCY ALERT: [Patient Name]'s medical QR was scanned.
Time: [HH:MM IST] | 📍 [Google Maps Link]
Responder: [Responder Name / Hospital or "Unknown"]
Please call 108 immediately.
- Golden Hour
```

WhatsApp (pre-approved template):
```
🔴 *EMERGENCY ALERT*
Patient: *[Name]*
Time: [HH:MM IST]
📍 Location: [Maps Link]
Responder: [Name/Hospital]
_Please call 108 or rush to location immediately._
_Powered by Golden Hour_
```

FCM Push (to patient):
```
Title: "⚠️ Your Medical QR Was Scanned"
Body:  "Scanned near [Area], [Time]. Tap to view details."
```

**Backend Endpoints**
| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/notifications/history` | GET | ✅ | Patient's scan + notification log |
| `/notifications/false-alarm/{scan_id}` | POST | ✅ | Mark scan event as false alarm |
| `/notifications/test` | POST | ✅ | Send test SMS/WhatsApp to self |

---

### Module 5 — 📂 Documents

**Flutter Screens**
| Screen | Description |
|---|---|
| Documents List | All uploaded docs with name, type, date |
| Upload Sheet | Bottom sheet: pick from gallery, camera, or files |
| Document Viewer | In-app PDF/image viewer |

**Supported Document Types**
- Prescription
- Lab Report
- Discharge Summary
- Insurance Card
- Other

**Backend Endpoints**
| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/documents/upload` | POST | ✅ | Upload file to Supabase Storage; save metadata |
| `/documents` | GET | ✅ | List all documents for patient |
| `/documents/{id}` | DELETE | ✅ | Remove from storage + DB |

> **Note**: Documents are **never shown** on the public responder page. Patient-only access.

---

### Module 6 — 📊 Scan History

**Flutter Screens**
| Screen | Description |
|---|---|
| Scan History List | Paginated list: time, location area, device type |
| Scan Detail | Full detail: timestamp, GPS, responder name, notifications sent |

**Features**
| Feature | Description |
|---|---|
| Scan Log | All scan events in reverse chronological order |
| Scan Detail | Tap to expand: see full GPS, responder info, notification status |
| False Alarm | "This was accidental" button — suppresses 60s after scan |

**Backend Endpoints**
| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/scan-events` | GET | ✅ | Paginated scan events for patient |
| `/scan-events/{id}` | GET | ✅ | Single scan event detail |
| `/scan-events/{id}/false-alarm` | PATCH | ✅ | Flag as false alarm |

---

## 6. Accounts to Create Before Setup

> ⚠️ **Create all of these on Day 1 before writing any code.**

### ✅ Mandatory — All Free

| # | Service | What For | URL |
|---|---|---|---|
| 1 | **GitHub** | Code hosting, CI/CD | github.com |
| 2 | **Supabase** | PostgreSQL + Auth + File Storage | supabase.com |
| 3 | **Firebase** | FCM push notifications (free, unlimited) | console.firebase.google.com |
| 4 | **Render.com** | Host FastAPI backend | render.com |
| 5 | **Cloudflare** | Host React web app + DNS + CDN | cloudflare.com |
| 6 | **Upstash** | Redis — Celery broker + session cache | upstash.com |
| 7 | **Fast2SMS** | SMS notifications (India — free credits on signup) | fast2sms.com |
| 8 | **Meta for Developers** | WhatsApp Cloud API (1,000 free conv/month) | developers.facebook.com |
| 9 | **Resend.com** | Email fallback (3,000 free/month) | resend.com |
| 10 | **Sentry** | Error tracking (5K errors/month free) | sentry.io |
| 11 | **Better Uptime** | Keep Render server warm (free ping every 10 min) | betteruptime.com |

### 💳 One-Time Payment Required

| # | Service | What For | Cost |
|---|---|---|---|
| 12 | **Google Play Console** | Publish app to Play Store | $25 one-time |

### 🔧 Dev Tools (Free)

| # | Service | What For |
|---|---|---|
| 13 | **Figma** | UI design |
| 14 | **Postman** | API testing |

---

## 7. Environment Variables

> **Single environment only.** No dev/prod/staging separation. One `.env` per service.

### Backend — `backend/.env`
```env
# JWT
SECRET_KEY=your-strong-random-jwt-secret
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=30

# Supabase
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
DATABASE_URL=postgresql+asyncpg://postgres:password@db.xxxx.supabase.co:5432/postgres?pgbouncer=true

# Redis (Upstash)
REDIS_URL=rediss://default:password@xxxx.upstash.io:6379

# Fast2SMS
FAST2SMS_API_KEY=your-api-key

# WhatsApp Cloud API
WHATSAPP_TOKEN=your-permanent-whatsapp-token
WHATSAPP_PHONE_NUMBER_ID=your-phone-number-id
WHATSAPP_TEMPLATE_NAME=emergency_alert

# Firebase Admin SDK
FIREBASE_CREDENTIALS_JSON=./firebase-service-account.json

# Resend (Email)
RESEND_API_KEY=re_xxxx
FROM_EMAIL=alerts@goldenhr.in

# Sentry
SENTRY_DSN=https://xxxx@sentry.io/xxxx

# Rate Limiting
MAX_SCANS_PER_QR_PER_HOUR=20
NOTIFICATION_DEDUP_MINUTES=5

# App
APP_BASE_URL=https://goldenhr.pages.dev
```

### Responder Web — `apps/responder-web/.env`
```env
VITE_API_BASE_URL=https://your-backend.onrender.com/api/v1
VITE_SENTRY_DSN=https://xxxx@sentry.io/xxxx
```

### Flutter — `apps/mobile/lib/core/constants/app_constants.dart`
```dart
class AppConstants {
  // Backend API
  static const String apiBaseUrl = 'https://your-backend.onrender.com/api/v1';

  // Responder web base URL
  static const String responderBaseUrl = 'https://goldenhr.pages.dev/p';

  // Supabase
  static const String supabaseUrl = 'https://xxxx.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
```

> **Security Note**: Add all `.env` files and `firebase-service-account.json` to `.gitignore`. Never commit secrets to GitHub.

---

## 8. 4-Week Build Roadmap

> **Goal**: Working app on Google Play Store by end of Week 4.

```
WEEK 1 — Foundation (Oct 13–19)
├── Day 1:  Create all accounts (Section 6); set up GitHub monorepo
├── Day 1:  Supabase: create project, enable Phone Auth, create DB tables, enable RLS
├── Day 1:  Firebase: create project, download google-services.json
├── Day 1:  Submit WhatsApp message template for pre-approval (takes 2-3 days!)
├── Day 2:  Backend: FastAPI project scaffold + DB models + Alembic migrations
├── Day 2:  Backend: Auth endpoints (send-otp, verify-otp, refresh, logout)
├── Day 3:  Backend: Profile CRUD endpoints + QR generate endpoint
├── Day 3:  Flutter: project init + GoRouter + Riverpod setup + theme
├── Day 4:  Flutter: Auth flow (Splash → Phone Input → OTP Verify → Home)
├── Day 5:  Flutter: Profile wizard (5 steps) + connect to backend
├── Day 5:  Flutter: Edit profile + privacy toggles
└── Day 7:  Deploy backend to Render; test all auth + profile APIs end-to-end

WEEK 2 — Core QR & Notifications (Oct 20–26)
├── Day 1:  Backend: /qr/public/{uid} endpoint + scan event logging
├── Day 1:  Backend: Celery setup with Upstash Redis
├── Day 2:  Backend: Celery notification task (SMS + WhatsApp + FCM + email)
├── Day 2:  Backend: Fast2SMS integration + test SMS delivery
├── Day 3:  Backend: WhatsApp Cloud API integration + test (template must be approved by now)
├── Day 3:  React Web: Vite project scaffold + React Router + emergency.css
├── Day 4:  React Web: EmergencyProfile page — fetch API + render all sections
├── Day 4:  React Web: Error states (NotFound, Deactivated) + print stylesheet
├── Day 5:  React Web: Location share button + responder name input
├── Day 5:  Deploy React web to Cloudflare Pages; test QR scan → page load
├── Day 6:  Flutter: QR display screen + download PNG + share
├── Day 6:  Flutter: In-app WebView preview of responder page
└── Day 7:  END-TO-END TEST: Register → fill profile → scan QR → verify all notifications fire

WEEK 3 — Polish + Remaining Features (Oct 27 – Nov 2)
├── Day 1:  Flutter: Scan history screen + scan detail screen
├── Day 1:  Flutter: False alarm button + FCM background handling
├── Day 2:  Flutter: PDF medical ID card generation + print/share
├── Day 2:  Flutter: QR regenerate flow + offline QR caching
├── Day 3:  Flutter: Document upload screen + Supabase Storage
├── Day 3:  Flutter: Settings screen (privacy toggles + logout + delete account)
├── Day 4:  React Web: Notification test from app (test SMS/WhatsApp to self)
├── Day 4:  Better Uptime: Set up server warm ping every 10 minutes
├── Day 5:  UI Polish: animations, transitions, empty states, error handling
├── Day 5:  Sentry: integrate in Flutter + React + backend
└── Day 6-7: Full regression testing on physical Android device

WEEK 4 — Play Store Submission (Nov 3–9)
├── Day 1:  Generate app icon (512x512) + feature graphic (1024x500)
├── Day 1:  Take Play Store screenshots (min 2, all required screens)
├── Day 1:  Write app short description (80 chars) + full description (4000 chars)
├── Day 2:  Create Privacy Policy page (required for Play Store health apps)
├── Day 2:  Create Terms of Service page
├── Day 2:  Set up Play Console account ($25) + create app listing
├── Day 3:  Generate release keystore: keytool -genkey -v -keystore release.jks
├── Day 3:  Configure android/app/build.gradle with signing config
├── Day 3:  Build release App Bundle: flutter build appbundle --release
├── Day 4:  Upload .aab to Play Console → Internal Testing track
├── Day 4:  Complete Play Console questionnaires (content rating, data safety)
├── Day 4:  Fill Data Safety form (what data is collected, how it's used)
├── Day 5:  Test Internal Testing build on real device
├── Day 5:  Fix any issues found in internal testing
├── Day 6:  Promote to Production track → Submit for Google review
└── Day 7:  Monitor review status (Google reviews take 3-7 days for new accounts)
```

---

## 9. Google Play Store — Publishing Guide

### 9.1 Requirements Checklist

| Requirement | Details |
|---|---|
| **Play Console Account** | $25 one-time fee at play.google.com/console |
| **App Icon** | 512x512 PNG, no alpha channel, no rounded corners (Google adds them) |
| **Feature Graphic** | 1024x500 PNG or JPG |
| **Screenshots** | Min 2, max 8 — phone form factor (16:9 or 9:16) |
| **Short Description** | Max 80 characters |
| **Full Description** | Max 4,000 characters |
| **Privacy Policy URL** | Must be a live public webpage (required for health apps) |
| **App Bundle** | `.aab` file (not `.apk`) |
| **Release Keystore** | Generated locally; keep the `.jks` file backed up — if lost, you can never update the app |
| **Target API Level** | Android 14 (API 34) minimum requirement from Google |
| **Content Rating** | Complete IARC questionnaire in Play Console |
| **Data Safety** | Declare what data is collected (blood group, phone, location) |

---

### 9.2 Step-by-Step: Build Release App Bundle

```bash
# Step 1: Generate release keystore (run ONCE, back it up!)
keytool -genkey -v \
  -keystore android/app/golden-hour-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias golden-hour

# Step 2: Add to android/key.properties (DO NOT commit this file!)
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=golden-hour
storeFile=golden-hour-release.jks

# Step 3: Update android/app/build.gradle to read key.properties
# (See Flutter docs: docs.flutter.dev/deployment/android)

# Step 4: Build release App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

### 9.3 Data Safety Form (What to Declare)

| Data Type | Collected? | Shared? | Purpose |
|---|---|---|---|
| Name | ✅ Yes | With emergency contacts (via notification) | App functionality |
| Phone number | ✅ Yes | Not shared | Account login |
| Health info (blood group, allergies) | ✅ Yes | Publicly visible via QR (user's choice) | App functionality |
| Location (approximate) | ✅ Yes (optional) | With emergency contacts | Emergency alerts |
| Device identifiers (FCM token) | ✅ Yes | Not shared | Push notifications |

---

### 9.4 Privacy Policy — Minimum Required Sections

Your Privacy Policy webpage must cover:
1. What data we collect and why
2. How data is stored and protected (AES-256, Supabase)
3. Who can see the data (responder page is public by user's choice)
4. How users can delete their data (in-app account deletion)
5. Contact email for privacy queries
6. DPDPA 2023 compliance statement

> **Free tool**: Use [privacypolicygenerator.info](https://privacypolicygenerator.info) to generate a base policy, then customize it.

---

### 9.5 Play Store Listing Content

**App Name**: Golden Hour — Medical QR ID

**Short Description** (80 chars):
```
Your medical QR code for emergencies. Help when you can't speak.
```

**Tags**: Medical, Emergency, Health, QR Code, Safety

---

## 10. Things You Might Have Missed

### 🔒 Security
- **No PII in QR URL**: QR contains only the opaque UID — never the patient's name, phone, or medical data.
- **QR Regeneration**: If a QR sticker is stolen/lost, patient can invalidate old UID and get a new one. Old URLs return 404.
- **Supabase RLS**: Enable Row Level Security on ALL tables before writing any data — patients can only access their own rows.
- **Rate Limiting**: 20 scans/hour per QR (via `slowapi`) prevents scraping/enumeration.
- **JWT Interceptor**: Dio interceptor in Flutter must silently refresh expired tokens. Test this edge case early.
- **Keystore Backup**: The release `.jks` file must be backed up to a secure location (Google Drive, etc.). If lost, you can NEVER update the Play Store app.

### 📱 Flutter Specific
- **No Build Flavors**: Single environment — use one `main.dart`, one `AppConstants` file. No flavor complexity.
- **Background FCM**: Must handle push notifications when app is in background or terminated. Use `firebase_messaging` `onBackgroundMessage` handler.
- **Offline QR**: Cache the patient's UID in `flutter_secure_storage` so the QR renders even without internet.
- **Android Permissions**: Declare in `AndroidManifest.xml`: `INTERNET`, `CAMERA` (for future scanning), `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` (for PDF/QR save), `POST_NOTIFICATIONS` (Android 13+).
- **Target SDK**: Must target API 34 (Android 14) for new Play Store apps.
- **Minimum SDK**: Set to API 21 (Android 5.0) for broad compatibility.

### 🌐 Responder Web (React)
- **Cloudflare `_redirects`**: Create `public/_redirects` with `/* /index.html 200`. Without this, direct URL access to `/p/uid` returns 404.
- **No JS Fallback**: Blood group and allergy data should render even if JS partially fails. Use `<noscript>` fallback text.
- **Accessibility**: Large fonts (min 16px), high contrast red for alerts, ARIA labels on call buttons. Doctors use this under stress.
- **Fast Load**: Keep entire page < 100KB. No heavy libraries. No Google Fonts (use system font stack for speed).

### 🔔 Notifications
- **WhatsApp Template Pre-Approval**: Submit template on Day 1. Takes 2-3 days. App is blocked without it.
- **Deduplication**: Same QR scanned twice within 5 minutes → suppress second notification. Prevents alert fatigue for family.
- **Retry with Backoff**: Celery retries failed SMS 3 times with 5s, 15s, 30s delays before falling back to email.
- **Test Feature**: Build a "Test Notification" button in the app — patients must verify their contacts receive alerts before they trust the system.

### ⚖️ Legal (Play Store Will Check)
- **Medical Disclaimer**: Responder page must show: *"Data self-reported by patient. Always verify clinically before treatment."*
- **Privacy Policy**: Must be a live URL before Play Store submission. Required for health apps.
- **Data Safety Form**: Fill accurately in Play Console — incorrect data safety declarations are grounds for removal.
- **DPDPA 2023**: Show consent checkbox at registration. Log consent timestamp. Provide in-app account deletion.

### 🚀 Deployment
- **Render Cold Start**: Free tier sleeps after 15 min idle. Set up Better Uptime to ping `/health` every 10 min — keeps server warm so first scan doesn't time out.
- **Supabase Connection**: Use `pgbouncer=true` in the DATABASE_URL string. Without it, you'll exhaust connections on the free tier.
- **Alembic**: Always run `alembic upgrade head` before deploying backend code. Never touch DB schema manually.
- **Cloudflare Cache**: The responder page fetches live data from backend, so set `Cache-Control: no-store` on API responses to prevent stale medical data.

### 📊 After Launch
- **PostHog** (free, open source): Add to Flutter + React to track where users drop off in the profile wizard.
- **Play Store Reviews**: Respond to all reviews in the first month — affects ranking.
- **Phone Number Format**: Store all phone numbers in **E.164 format** (`+91XXXXXXXXXX`) from Day 1. This is critical for WhatsApp and SMS delivery.
- **Date Format**: Store all timestamps as UTC ISO 8601 in DB. Display in IST in the app.

---

## Quick Start Checklist (Day 1)

```
□ Create GitHub repo (monorepo: golden-hour/)
□ Create Supabase project → enable Phone Auth → create tables → enable RLS
□ Create Firebase project → enable FCM → download google-services.json
□ Create Cloudflare account → create Pages project → connect GitHub
□ Create Render.com account → create Web Service → connect GitHub
□ Create Upstash account → create Redis DB → copy Redis URL
□ Register Fast2SMS → get API key + test SMS delivery
□ Apply for WhatsApp Cloud API → create + submit emergency_alert template ⚠️ DO THIS FIRST
□ Create Resend.com account → get API key → verify sending domain
□ Create Sentry projects (backend + web) → copy DSNs
□ Create Better Uptime account → add monitor for Render /health endpoint (10 min interval)
□ Pay $25 → create Google Play Console account
□ Set up all .env files from Section 7
□ Add .env + firebase-service-account.json to .gitignore
□ Run flutter create inside apps/mobile/
□ Run npm create vite@latest inside apps/responder-web/
□ Scaffold FastAPI project inside backend/
□ Run initial Alembic migration to create all DB tables
□ Deploy backend → test GET /health returns 200
□ Deploy React web → add _redirects → test /p/test-uid loads
□ Run Flutter on Android emulator → test OTP login
□ END-TO-END TEST: Register → fill profile → scan QR → verify notification fires
```

---

*Document: PROJECT_BLUEPRINT.md | Golden Hour | Version 2.0 | October 2026*  
*Target: Google Play Store launch by November 9, 2026*

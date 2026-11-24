# Changelog

All notable changes to the Golden Hour platform will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Disclaimer:** Golden Hour is a non-clinical emergency safety QR code and ICE (In Case of Emergency) notification platform governed by India DPDPA 2023. It does not provide medical treatment, diagnosis, or clinical triage.

---

## [1.0.4] - 2026-11-24

### Added
- **Phase 1 — Offline Emergency Response Guides**: Bundled 5 offline first-aid and safety guides in markdown format with category filtering, search, and local caching.
- **Phase 2 — Enhanced Contact Groups & Quick-Dial**: Contact categorization (`family`, `doctor`, `work`, `other`), broadcast alerting APIs, and quick-dial chips for statutory emergency services (112, 108, 100).
- **Phase 3 — Real-Time Location Sharing & Safe-Zone Radar**: WebSocket location telemetry stream, Haversine proximity calculations, geofence radius boundary alerts, and interactive radar canvas.
- **Phase 4 — FCM Push Enhancements & Data-Only Payloads**: Multi-category push notifications (`emergency_sos`, `safety_tip`, `app_update`, `radar_alert`), in-app push composer, and deep-link routing.
- **Phase 5 — Dark Mode & Dynamic Theming**: 8-accent curated color palette, dynamic `ThemeMode` switching, and secure persistent appearance preferences.
- **Phase 6 — Multi-Language Support**: Official localization for English (`en`), Hindi (`hi`), and Spanish (`es`) with dynamic in-app locale switcher.
- **Phase 7 — Accessibility Enhancements**: WCAG 2.1 AA compliant color contrast ratios, $\ge 48\times 48\text{ dp}$ tap targets, and comprehensive TalkBack semantics.
- **Phase 8 — Onboarding Flow Redesign**: 4-slide responsive `PageView` wizard introducing key emergency safety concepts with skip logic and persistent completion tracking.
- **Phase 9 — CI/CD Pipeline (GitHub Actions)**: Automated multi-stage GitHub Actions workflow covering linting (`flutter analyze`, `ruff`), unit & widget testing (`flutter test`, `pytest`), Android APK/AAB build artifacts, backend Docker container builds to GHCR, and semantic release publishing.
- **Phase 10 — Test Suite Expansion**: Comprehensive test coverage expansion across mobile and backend:
  - Mobile widget tests for `PhoneInputScreen`, `OtpVerifyScreen`, and `EditProfileScreen`.
  - Mobile end-to-end (E2E) integration test flow (`integration_test/app_e2e_test.dart` and `test/e2e_flow_test.dart`) exercising authentication, profile setup, QR generation, scan events, and offline first-aid guides.
  - Backend integration and unit tests for Profile endpoints (`/me`, `/completion`, `/privacy`, `/status`, account deletion/right-to-erasure) and Scan Events endpoints (paginated scans, scan detail, false-alarm toggle).
  - Integration of `pytest-cov` and `flutter test --coverage` test coverage reporting in CI/CD pipeline.
- **Phase 11 — Analytics Integration**: End-to-end telemetry and user engagement tracking:
  - Added `firebase_analytics` (`^11.4.0`) to Flutter mobile app with defensive headless fallback in `AnalyticsService`.
  - Structured event mapping for `guide_viewed`, `contact_broadcast`, `sos_triggered`, `theme_changed`, `qr_shared`, and `language_changed`.
  - Backend Google Analytics 4 (GA4) Measurement Protocol client for admin audit actions (`admin_false_alarm_flagged`, `admin_contact_broadcast`, `admin_qr_status_toggled`).
  - Unit tests for both mobile `AnalyticsService` and backend GA4 Measurement Protocol service.
- **Phase 12 — Docker Compose for Local Development**: Complete local environment orchestration:
  - Created `docker-compose.yml` orchestrating `backend` (FastAPI), `db` (Postgres 15 Alpine), `redis` (Redis 7 Alpine), and `admin-web` (React/Vite on Nginx Alpine).
  - Scaffolded `apps/admin-web/` with Vite, TypeScript, Nginx multi-stage Dockerfile, and health-monitoring admin UI.
  - Added canonical `.env.example` environment template with comprehensive configuration documentation.
  - Rewrote root `README.md` with detailed Docker Compose quick-start, service port mappings, migration workflows, and testing instructions.

### Changed
- Refactored medical terminology across UI, documentation, and metadata to ensure strict non-clinical compliance under India DPDPA 2023.
- Standardized Android signing configuration in `build.gradle.kts` with automatic fallback to debug signing when release keystore is absent in CI.

---

## [1.0.3] - 2026-10-24
### Added
- DPDPA 2023 privacy controls and field visibility toggles.
- Offline emergency QR code generator with secure 256-bit AES encryption.
- Direct ICE notification dispatch via SMS and WhatsApp Cloud API.


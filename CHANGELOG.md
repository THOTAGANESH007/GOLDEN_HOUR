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

### Changed
- Refactored medical terminology across UI, documentation, and metadata to ensure strict non-clinical compliance under India DPDPA 2023.
- Standardized Android signing configuration in `build.gradle.kts` with automatic fallback to debug signing when release keystore is absent in CI.

---

## [1.0.3] - 2026-10-24
### Added
- DPDPA 2023 privacy controls and field visibility toggles.
- Offline emergency QR code generator with secure 256-bit AES encryption.
- Direct ICE notification dispatch via SMS and WhatsApp Cloud API.


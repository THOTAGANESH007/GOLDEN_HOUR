# ✅ Enhancements — Implementation Checklist

> **How to use this file:**
> - Mark items as done: change `[ ]` → `[x]`
> - Add the completion date next to each item when done: `[x] Feature Name ✦ 2026-11-XX`
> - Add notes or blockers inline using `<!-- note: ... -->`
> - Commit this file after every working session so progress is always tracked

*Branch:* `next-updates`

---

## 🏗️ Phase 1 — Offline First‑Aid Guides

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define `GuideModel` fields (`id`, `title`, `category`, `content`, `lastUpdated`) | |
| [ ] | Create UI wireframes for guide list screen and detail screen | |
| [ ] | Identify initial set of first‑aid guide topics (burns, bleeding, CPR, fractures, etc.) | |
| [ ] | Choose cache strategy (`flutter_cache_manager` vs `hive`) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/offline_guides/data/guide_model.dart` | |
| [ ] | Create `lib/features/offline_guides/data/guide_repository.dart` — loads from `assets/guides/` | |
| [ ] | Create `lib/features/offline_guides/domain/guide_provider.dart` — Riverpod provider | |
| [ ] | Create `lib/features/offline_guides/domain/guide_state.dart` | |
| [ ] | Create `lib/features/offline_guides/presentation/guides_screen.dart` — list with search bar | |
| [ ] | Create `lib/features/offline_guides/presentation/guide_detail_screen.dart` — markdown renderer | |
| [ ] | Add `flutter_markdown` and `flutter_cache_manager` dependencies to `pubspec.yaml` | |
| [ ] | Write first‑aid guide markdown files under `assets/guides/` | |
| [ ] | Register guide assets in `pubspec.yaml` | |
| [ ] | Add route for guides in `app_router.dart` | |
| [ ] | Add navigation entry to home screen / bottom nav | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: `guide_repository` loads all guides from assets | |
| [ ] | Unit test: search/filter returns correct guides | |
| [ ] | Widget test: `guides_screen` renders list correctly | |
| [ ] | Widget test: `guide_detail_screen` renders markdown content | |
| [ ] | Integration test: simulate offline mode → guides still display | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | UI/UX validation on Android device | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 2 — Enhanced Emergency Contact Management

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define contact grouping schema (`groupId`, `groupName`) | |
| [ ] | Wireframe group management UI and quick‑dial widget | |
| [ ] | Define broadcast message template (SMS / WhatsApp) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Extend `emergency_contact` model with `group_id` field in backend | |
| [ ] | Create Alembic migration for `group_id` column | |
| [ ] | Create backend endpoint `POST /api/v1/contacts/broadcast` — sends SMS/WhatsApp to group | |
| [ ] | Update `contact_model.dart` in Flutter with group support | |
| [ ] | Create `contact_group_screen.dart` — manage groups (create, rename, delete) | |
| [ ] | Create `quick_dial_button.dart` — home screen widget, launches dialer for primary contact | |
| [ ] | Update `profile_provider.dart` to support grouped contacts | |
| [ ] | Add Twilio / Fast2SMS integration for group broadcast in backend | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: broadcast endpoint sends to all group members | |
| [ ] | Backend unit test: group CRUD operations | |
| [ ] | Widget test: `contact_group_screen` renders groups correctly | |
| [ ] | Widget test: `quick_dial_button` launches correct phone number | |
| [ ] | Integration test: create group → add contacts → broadcast | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Security review for SMS gateway credentials | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 3 — Real‑time Location Sharing

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define WebSocket message schema (`userId`, `lat`, `lon`, `timestamp`) | |
| [ ] | Design live map UI layout with peer markers | |
| [ ] | Define geofence safe‑zone radius (configurable) | |
| [ ] | Review privacy implications and consent flow | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend: create WebSocket endpoint `/ws/location` using `fastapi-websocket` | |
| [ ] | Backend: store latest positions in Redis with TTL | |
| [ ] | Backend: create `GET /api/v1/location/peers` — fetch nearby peers | |
| [ ] | Add `redis` dependency to backend `requirements.txt` | |
| [ ] | Flutter: create `lib/core/services/location_service.dart` using `geolocator` | |
| [ ] | Flutter: create `lib/features/location/presentation/live_map_screen.dart` using `google_maps_flutter` | |
| [ ] | Flutter: create `lib/features/location/data/location_repository.dart` | |
| [ ] | Flutter: create `lib/features/location/domain/location_provider.dart` | |
| [ ] | Flutter: create `lib/core/services/geofence_service.dart` — local notification on zone exit | |
| [ ] | Add `geolocator`, `google_maps_flutter`, `socket_io_client` to `pubspec.yaml` | |
| [ ] | Add location permissions to `AndroidManifest.xml` | |
| [ ] | Add route for live map in `app_router.dart` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: WebSocket accepts and stores position in Redis | |
| [ ] | Backend unit test: peers endpoint returns correct data | |
| [ ] | Widget test: `live_map_screen` renders map with markers | |
| [ ] | Unit test: `geofence_service` triggers notification on zone exit | |
| [ ] | Integration test: location emitted → peer sees updated marker | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Privacy & performance review | |
| [ ] | Tested on physical Android device with GPS | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 4 — Push Notification System (FCM Enhancements)

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define data‑only payload schema for SOS alerts | |
| [ ] | Define notification categories (SOS, health tip, app update) | |
| [ ] | Design admin notification composer UI (covered in adminpanel.md) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Extend `fcm_service.dart` to parse data‑only payloads | |
| [ ] | Add routing logic: SOS → open scan detail, health tip → open guides | |
| [ ] | Backend: create `POST /api/v1/notifications/push` (title, body, targetIds, category) | |
| [ ] | Backend: integrate with existing `notification_service.py` for FCM dispatch | |
| [ ] | Add analytics event `notification_sent` to backend | |
| [ ] | Add analytics event `notification_opened` to Flutter | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: FCM payload builder produces correct JSON | |
| [ ] | Unit test: routing logic navigates to correct screen | |
| [ ] | Backend unit test: push endpoint validates input and calls FCM | |
| [ ] | End‑to‑end test: admin sends push → device receives and displays | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Verify push key security | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 5 — Dark Mode & Theming

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define accent color palette (5–8 choices) | |
| [ ] | Design settings UI for theme toggle and color picker | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/core/theme/theme_customizer.dart` — Riverpod provider for accent color | |
| [ ] | Update `app_theme.dart` to accept dynamic accent color | |
| [ ] | Add dark mode toggle and color picker to `settings_screen.dart` | |
| [ ] | Persist selected theme and accent color via `secure_storage_service` | |
| [ ] | Ensure all screens respect dynamic theme (audit each screen) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Widget test: toggling dark mode switches theme | |
| [ ] | Widget test: changing accent color updates UI | |
| [ ] | Unit test: preferences persist across app restarts | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Visual regression check on light and dark themes | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 6 — Multi‑Language Support (i18n)

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Identify all user‑visible strings across all screens | |
| [ ] | Choose initial locales: English (`en`), Hindi (`hi`), Spanish (`es`) | |
| [ ] | Define translation workflow (ARB files) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `flutter_localizations` and `intl` dependencies to `pubspec.yaml` | |
| [ ] | Configure `l10n.yaml` for ARB file generation | |
| [ ] | Create `lib/l10n/app_en.arb` — English strings | |
| [ ] | Create `lib/l10n/app_hi.arb` — Hindi strings | |
| [ ] | Create `lib/l10n/app_es.arb` — Spanish strings | |
| [ ] | Replace all hardcoded strings with `AppLocalizations.of(context)!.keyName` | |
| [ ] | Add language selector dropdown in `settings_screen.dart` | |
| [ ] | Persist selected locale via `secure_storage_service` | |
| [ ] | Update `MaterialApp.router` with `localizationsDelegates` and `supportedLocales` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: switching locale changes displayed text | |
| [ ] | Widget test: settings language selector updates app locale | |
| [ ] | CI step: verify all ARB files have matching keys | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Linguistic quality check for Hindi and Spanish translations | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 7 — Accessibility Improvements

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Run initial accessibility audit with `flutter_a11y` tool | |
| [ ] | Document all WCAG AA violations | |
| [ ] | Plan fixes (tap targets, contrast, semantic labels) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Increase all interactive element tap targets to ≥48 dp | |
| [ ] | Add `Semantics` labels to all icons and images | |
| [ ] | Fix color contrast violations to meet WCAG AA (4.5:1 ratio) | |
| [ ] | Add `excludeSemantics` where needed to avoid redundancy | |
| [ ] | Test with Android TalkBack enabled | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Run `flutter_a11y` lint — zero violations | |
| [ ] | Manual TalkBack walkthrough on physical device | |
| [ ] | Add accessibility lint step to CI workflow | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Accessibility expert sign‑off | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 8 — Onboarding Flow Redesign

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design onboarding screens (3–5 slides with illustrations) | |
| [ ] | Define progress indicator style (dots / bar) | |
| [ ] | Plan skip logic and consent handling | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/onboarding/presentation/onboarding_screen.dart` — `PageView` wizard | |
| [ ] | Add progress indicator widget (dots at bottom) | |
| [ ] | Add "Skip" button — sets `onboarding_complete` flag in secure storage | |
| [ ] | Add "Get Started" button on last slide — navigates to login | |
| [ ] | Update `splash_screen.dart` — check `onboarding_complete` flag before routing | |
| [ ] | Add onboarding illustrations under `assets/images/onboarding/` | |
| [ ] | Register onboarding assets in `pubspec.yaml` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: navigation logic (next, back, skip) works correctly | |
| [ ] | Widget test: all slides render with correct content | |
| [ ] | Integration test: first launch → onboarding → login → subsequent launch skips onboarding | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | UX walkthrough completed | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 9 — CI/CD Pipeline (GitHub Actions)

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define CI workflow jobs: lint, test, build, docker, release | |
| [ ] | Choose release strategy: `semantic-release` with conventional commits | |
| [ ] | Define trigger rules: on push to `next-updates`, on tag push for release | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `.github/workflows/ci.yml` | |
| [ ] | Add **lint** job: `flutter analyze` + `ruff check` (Python) | |
| [ ] | Add **test** job: `flutter test` + `pytest` (backend) | |
| [ ] | Add **build** job: `flutter build apk --release` + `flutter build appbundle` | |
| [ ] | Add **docker** job: build backend Docker image, push to GHCR | |
| [ ] | Add **release** job: on tag push, upload AAB as GitHub release artifact | |
| [ ] | Configure repository secrets: `KEYSTORE_BASE64`, `KEY_PASSWORD`, `FIREBASE_TOKEN` | |
| [ ] | Add `semantic-release` config (`release.config.js`) for version bumping | |
| [ ] | Add `CHANGELOG.md` auto‑generation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | CI workflow runs successfully on push | |
| [ ] | All lint jobs pass | |
| [ ] | All test jobs pass | |
| [ ] | APK/AAB artifacts uploaded correctly | |
| [ ] | Docker image builds and pushes to registry | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | CI pipeline reviewed by DevOps | |
| [ ] | Secrets verified (no exposure in logs) | |
| [ ] | Merged to `next-updates` branch | |

---

## 🏗️ Phase 10 — Test Suite Expansion

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Identify untested Flutter screens and backend endpoints | |
| [ ] | Define target coverage percentage (≥70%) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add widget tests for all new enhancement screens (guides, contacts, map, onboarding) | |
| [ ] | Add backend unit tests for all new API endpoints | |
| [ ] | Create `integration_test/` folder in Flutter project | |
| [ ] | Write end‑to‑end test: login → create profile → generate QR → scan → SOS | |
| [ ] | Add test coverage reporting to CI (`flutter test --coverage`) | |

### Testing & Review
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Coverage report generated and reviewed | |
| [ ] | All new tests pass in CI | |
| [ ] | Merged to `next-updates` branch | |

---

## 🏗️ Phase 11 — Analytics Integration

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define analytics events: `guide_viewed`, `contact_broadcast`, `sos_triggered`, `theme_changed`, `qr_shared` | |
| [ ] | Map each event to screen / action | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `firebase_analytics` dependency to `pubspec.yaml` | |
| [ ] | Create `lib/core/services/analytics_service.dart` — wrapper for logging events | |
| [ ] | Add `logEvent()` calls in all relevant screens and providers | |
| [ ] | Backend: log admin actions via Google Analytics Measurement Protocol | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: analytics service sends correct event names and parameters | |
| [ ] | Verify events appear in Firebase Analytics dashboard | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 12 — Docker Compose for Local Development

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define services: `backend`, `admin-web`, `db` (Postgres), `redis` | |
| [ ] | Define port mappings and volume mounts | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `docker-compose.yml` at repo root | |
| [ ] | Configure `backend` service (build from `./backend`, env_file, port 8000) | |
| [ ] | Configure `db` service (postgres:15-alpine, persistent volume) | |
| [ ] | Configure `redis` service (redis:7-alpine, port 6379) | |
| [ ] | Configure `admin-web` service (build from `./apps/admin-web`, port 3000) | |
| [ ] | Add `.env.example` with all required environment variables | |
| [ ] | Update `README.md` with Docker Compose quick‑start instructions | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | `docker compose up` starts all services without errors | |
| [ ] | Backend `/health` returns `200` | |
| [ ] | Database migrations run successfully in container | |
| [ ] | Admin web UI accessible at `http://localhost:3000` | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 13 — Versioning & Release Automation

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Choose versioning scheme: Semantic Versioning (MAJOR.MINOR.PATCH) | |
| [ ] | Define commit message convention (Conventional Commits) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Install and configure `semantic-release` (`release.config.js`) | |
| [ ] | Configure to update version in `pubspec.yaml` and backend `pyproject.toml` | |
| [ ] | Add `CHANGELOG.md` auto‑generation plugin | |
| [ ] | Add CI release job: triggers on push to `main` after merge | |
| [ ] | Create `CONTRIBUTING.md` with commit message guidelines | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Test release workflow with a dry‑run | |
| [ ] | Verify `CHANGELOG.md` is generated correctly | |
| [ ] | Verify version bump in `pubspec.yaml` | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 📈 Enhancements Progress Summary

| Phase | Total | Done | Remaining |
|-------|-------|------|-----------|
| Phase 1 — Offline First‑Aid Guides | 20 | 0 | 20 |
| Phase 2 — Emergency Contact Management | 16 | 0 | 16 |
| Phase 3 — Real‑time Location Sharing | 21 | 0 | 21 |
| Phase 4 — Push Notifications (FCM) | 14 | 0 | 14 |
| Phase 5 — Dark Mode & Theming | 10 | 0 | 10 |
| Phase 6 — Multi‑Language Support | 16 | 0 | 16 |
| Phase 7 — Accessibility Improvements | 12 | 0 | 12 |
| Phase 8 — Onboarding Flow Redesign | 14 | 0 | 14 |
| Phase 9 — CI/CD Pipeline | 17 | 0 | 17 |
| Phase 10 — Test Suite Expansion | 8 | 0 | 8 |
| Phase 11 — Analytics Integration | 8 | 0 | 8 |
| Phase 12 — Docker Compose | 11 | 0 | 11 |
| Phase 13 — Versioning & Release | 11 | 0 | 11 |
| **TOTAL** | **178** | **0** | **178** |

---

*Last updated: 2026-11-14 | Branch: `next-updates`*

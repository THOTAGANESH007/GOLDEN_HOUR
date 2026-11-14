# ✅ Next Features — Roadmap & Implementation Checklist

> **How to use this file:**
> - Mark items as done: change `[ ]` → `[x]`
> - Add the completion date next to each item when done: `[x] Feature Name ✦ 2026-XX-XX`
> - Add notes or blockers inline using `<!-- note: ... -->`
> - Commit this file after every working session so progress is always tracked

*Branch:* `next-updates`

---

## 🏗️ Phase 1 — Wearable Integration

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define wearable device registration API contract (`POST /api/v1/wearable/register`) | |
| [ ] | Design minimal watch app UI mockups (QR display, SOS button) | |
| [ ] | Define security model (mutual TLS between watch and backend) | |
| [ ] | Choose target platforms: Wear OS (initial), Apple Watch (future) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/wearable.py` — router file | |
| [ ] | Add `POST /api/v1/wearable/register` — stores device token linked to user | |
| [ ] | Add `POST /api/v1/wearable/sos` — triggers SOS from watch (same flow as QR scan) | |
| [ ] | Add `GET /api/v1/wearable/profile-summary` — minimal medical info for watch display | |
| [ ] | Extend FCM service to send data‑only messages to Wear OS devices | |
| [ ] | Create `backend/app/models/wearable_device.py` — device model (`id`, `user_id`, `token`, `platform`, `registered_at`) | |
| [ ] | Create Alembic migration for `wearable_devices` table | |

### Flutter / Watch App Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/core/services/wearable_service.dart` using `wear` package | |
| [ ] | Implement device registration flow (pair watch → register token) | |
| [ ] | Implement SOS trigger via hardware button press listener | |
| [ ] | Create minimal watch face widget: QR code + blood group | |
| [ ] | Add connection status indicator (connected / disconnected) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: device registration stores token correctly | |
| [ ] | Backend unit test: wearable SOS triggers notification pipeline | |
| [ ] | Backend unit test: profile summary returns only minimal fields | |
| [ ] | Emulator test: watch app registers and sends SOS successfully | |
| [ ] | Integration test: watch SOS → backend → FCM push to emergency contacts | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Security audit of device‑backend communication | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 2 — AI‑Powered Triage

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design prompt template for Gemini API (symptom → first-aid suggestions) | |
| [ ] | Design triage screen UI mockup (text input, loading state, result cards) | |
| [ ] | Define safety requirements (medical disclaimer, rate limits, usage logging) | |
| [ ] | Define fallback behaviour when API is unavailable | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/ai.py` — router file | |
| [ ] | Add `POST /api/v1/ai/triage` — accepts symptom text, forwards to Gemini, returns suggestions | |
| [ ] | Create `backend/app/services/gemini_service.py` — Gemini API wrapper with prompt template | |
| [ ] | Add rate limiting: 10 requests per user per hour | |
| [ ] | Log all triage requests in DB for auditing (`ai_triage_log` table) | |
| [ ] | Create Alembic migration for `ai_triage_log` table | |
| [ ] | Add `GEMINI_API_KEY` to config and `.env.example` | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/ai_triage/data/triage_models.dart` — request/response models | |
| [ ] | Create `lib/features/ai_triage/data/triage_repository.dart` — API integration | |
| [ ] | Create `lib/features/ai_triage/domain/triage_provider.dart` — Riverpod provider | |
| [ ] | Create `lib/features/ai_triage/domain/triage_state.dart` | |
| [ ] | Create `lib/features/ai_triage/presentation/ai_triage_screen.dart` — text input, loading, results | |
| [ ] | Add medical disclaimer banner at top of screen | |
| [ ] | Add route for AI triage in `app_router.dart` | |
| [ ] | Add navigation entry to home screen | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: triage endpoint validates input (non‑empty symptom text) | |
| [ ] | Backend unit test: Gemini service returns structured suggestions (mock API) | |
| [ ] | Backend unit test: rate limiter blocks excess requests | |
| [ ] | Backend unit test: triage log records request in DB | |
| [ ] | Widget test: `ai_triage_screen` renders input, loading, and result states | |
| [ ] | Widget test: disclaimer is always visible | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Medical disclaimer reviewed and approved | |
| [ ] | Usage logging verified in audit table | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 3 — Community Forum

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define data model: `forum_thread` (`id`, `author_id`, `title`, `created_at`) | |
| [ ] | Define data model: `forum_post` (`id`, `thread_id`, `author_id`, `content`, `created_at`) | |
| [ ] | Define moderation roles: `moderator` can edit/delete posts, ban users | |
| [ ] | Design forum UI wireframes (thread list, thread detail, post editor) | |
| [ ] | Define real‑time update mechanism (WebSocket `/ws/forum`) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/forum_thread.py` — ForumThread model | |
| [ ] | Create `backend/app/models/forum_post.py` — ForumPost model | |
| [ ] | Create Alembic migration for `forum_thread` and `forum_post` tables | |
| [ ] | Create `backend/app/api/v1/forum.py` — router file | |
| [ ] | Add `GET /api/v1/forum/threads` — paginated thread list | |
| [ ] | Add `POST /api/v1/forum/threads` — create new thread | |
| [ ] | Add `GET /api/v1/forum/threads/{id}` — thread detail with posts | |
| [ ] | Add `POST /api/v1/forum/threads/{id}/posts` — add post to thread | |
| [ ] | Add `DELETE /api/v1/forum/posts/{id}` — moderator delete | |
| [ ] | Add `PATCH /api/v1/forum/posts/{id}` — moderator edit | |
| [ ] | Create WebSocket endpoint `/ws/forum` for live updates | |
| [ ] | Create `backend/app/api/v1/admin/forum.py` — admin moderation endpoints | |

### Frontend Development (Admin Panel)
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Forum/ForumThreadList.tsx` — thread list with search | |
| [ ] | Create `src/pages/Forum/ForumThreadDetail.tsx` — posts with moderation actions | |
| [ ] | Create `src/components/PostEditor.tsx` — markdown editor using `react-markdown` | |
| [ ] | Add "Forum" entry to admin sidebar navigation | |
| [ ] | Implement real‑time post updates via WebSocket | |

### Flutter Development (Mobile Forum)
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/forum/data/forum_models.dart` | |
| [ ] | Create `lib/features/forum/data/forum_repository.dart` | |
| [ ] | Create `lib/features/forum/domain/forum_provider.dart` | |
| [ ] | Create `lib/features/forum/presentation/forum_screen.dart` — thread list | |
| [ ] | Create `lib/features/forum/presentation/thread_detail_screen.dart` — posts + reply | |
| [ ] | Add route for forum in `app_router.dart` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: thread CRUD operations | |
| [ ] | Backend unit test: post CRUD operations | |
| [ ] | Backend unit test: moderator can delete/edit any post | |
| [ ] | Backend unit test: regular user cannot delete others' posts | |
| [ ] | Frontend Jest test: thread list renders correctly | |
| [ ] | Frontend Jest test: post editor submits content | |
| [ ] | Cypress E2E test: create thread → add post → moderator deletes post | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Content moderation policy defined | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 4 — Offline Sync Mechanism

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define sync queue architecture (Hive local DB for pending actions) | |
| [ ] | Define conflict resolution strategy: last‑write‑wins with timestamps | |
| [ ] | Define syncable entities: documents, contacts, profile updates | |
| [ ] | Design network monitor spec (connectivity listener) | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `hive` and `connectivity_plus` dependencies to `pubspec.yaml` | |
| [ ] | Create `lib/core/services/sync_queue.dart` — Hive‑backed queue for pending API calls | |
| [ ] | Create `lib/core/services/network_monitor.dart` — detects online/offline transitions | |
| [ ] | Create `lib/core/services/sync_worker.dart` — background isolate that processes queue | |
| [ ] | Implement exponential back‑off retry (3 retries: 2s, 4s, 8s) | |
| [ ] | Integrate sync queue into `document_repository.dart` — queue uploads when offline | |
| [ ] | Integrate sync queue into `profile_repository.dart` — queue profile updates when offline | |
| [ ] | Add sync status indicator widget (syncing / synced / offline) | |
| [ ] | Show pending sync count badge on home screen | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: `sync_queue` enqueues actions correctly | |
| [ ] | Unit test: `sync_worker` processes queue and calls correct APIs | |
| [ ] | Unit test: exponential back‑off delays are correct | |
| [ ] | Integration test: go offline → make changes → go online → verify data synced | |
| [ ] | Integration test: conflict resolution applies last‑write‑wins correctly | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Performance impact assessment (battery, storage) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 5 — Exportable Health Report (PDF)

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define PDF report layout (header with logo, sections for blood group, allergies, conditions, medications, contacts) | |
| [ ] | Define sharing options (save to device, share via intent, email) | |
| [ ] | Review legal requirements for medical data PDF export | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `pdf` and `printing` dependencies to `pubspec.yaml` | |
| [ ] | Create `lib/core/services/pdf_report_service.dart` — generates PDF from profile data | |
| [ ] | Build PDF sections: header, blood group card, allergies list, conditions list, medications table, emergency contacts | |
| [ ] | Add app logo and branding to PDF header | |
| [ ] | Add generation timestamp and disclaimer footer to PDF | |
| [ ] | Create "Export Report" button on `profile_home_screen.dart` | |
| [ ] | Add `PdfPreview` widget for in‑app preview before saving | |
| [ ] | Integrate `share_plus` for sharing generated PDF | |
| [ ] | Save generated PDFs in app cache directory | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: PDF service generates document with all sections | |
| [ ] | Unit test: PDF contains correct user data | |
| [ ] | Unit test: PDF file size is within acceptable limits (<5 MB) | |
| [ ] | Widget test: Export button triggers PDF generation flow | |
| [ ] | Integration test: generate PDF → preview → share | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Legal compliance review for medical data export | |
| [ ] | PDF visual review (formatting, readability) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 6 — Enterprise Multi‑Tenant Mode

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define tenant isolation model (shared DB with `tenant_id` column) | |
| [ ] | Define tenant onboarding flow (admin creates tenant → assigns admin user) | |
| [ ] | Design tenant admin management UI wireframe | |
| [ ] | Choose routing strategy: sub‑domain (`hospital1.goldenhour.com`) or path (`/tenant/hospital1`) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/tenant.py` — Tenant model (`id`, `name`, `domain`, `status`, `created_at`) | |
| [ ] | Add `tenant_id` column to `users`, `profiles`, `documents`, `scan_events` tables | |
| [ ] | Create Alembic migration for tenant schema changes | |
| [ ] | Create `backend/app/middleware/tenant_middleware.py` — resolves tenant from sub‑domain or header | |
| [ ] | Extend JWT claims with `tenant_id` | |
| [ ] | Add tenant filtering to all existing queries (automatic via SQLAlchemy event listener) | |
| [ ] | Create `backend/app/api/v1/admin/tenants.py` — `GET /admin/tenants`, `POST /admin/tenants`, `PATCH /admin/tenants/{id}` | |
| [ ] | Add `SUPER_ADMIN` restriction: only super‑admin can create/manage tenants | |

### Frontend Development (Admin Panel)
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Tenants/TenantList.tsx` — list with status, user count | |
| [ ] | Create `src/pages/Tenants/TenantCreate.tsx` — create new tenant form | |
| [ ] | Create `src/pages/Tenants/TenantDetail.tsx` — tenant settings, assigned admins | |
| [ ] | Add "Tenants" entry to sidebar (visible to `SUPER_ADMIN` only) | |
| [ ] | Add tenant context switcher in header (for multi‑tenant admins) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: tenant middleware resolves correct tenant from sub‑domain | |
| [ ] | Backend unit test: queries filter by `tenant_id` automatically | |
| [ ] | Backend unit test: user in tenant A cannot see data from tenant B | |
| [ ] | Backend unit test: tenant CRUD endpoints work correctly | |
| [ ] | Frontend Jest test: `TenantList.tsx` renders with mock data | |
| [ ] | Integration test: create tenant → create user in tenant → verify isolation | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Security review of tenant data boundaries | |
| [ ] | Performance review (tenant filtering doesn't degrade queries) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 7 — Advanced Reporting & Export

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define report types: SOS Events, Response Times, Device Statistics, User Growth | |
| [ ] | Define export formats: CSV, Excel (XLSX) | |
| [ ] | Design export UI (report type selector, date range, format, download button) | |
| [ ] | Define optional scheduled report (nightly email to admins) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `pandas` and `openpyxl` to `requirements.txt` | |
| [ ] | Create `backend/app/api/v1/admin/reports.py` — router file | |
| [ ] | Add `GET /admin/reports/sos?format=csv&start=&end=` — SOS event report | |
| [ ] | Add `GET /admin/reports/response-times?format=xlsx` — response time analysis | |
| [ ] | Add `GET /admin/reports/users?format=csv` — user growth report | |
| [ ] | Add `GET /admin/reports/devices?format=csv` — device/OS distribution | |
| [ ] | Create `backend/app/tasks/report_tasks.py` — Celery task for scheduled nightly report email | |
| [ ] | Add admin setting `NIGHTLY_REPORT_ENABLED` and `NIGHTLY_REPORT_EMAIL` | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Reports/ReportGenerator.tsx` — report type selector, date range, format, download | |
| [ ] | Create `src/services/reportService.ts` — API calls for report download | |
| [ ] | Add "Reports" entry to sidebar navigation | |
| [ ] | Implement file download via `file-saver` package | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: CSV export contains correct columns and data | |
| [ ] | Backend unit test: XLSX export is valid Excel file | |
| [ ] | Backend unit test: date range filtering works correctly | |
| [ ] | Backend unit test: scheduled report task sends email | |
| [ ] | Frontend Jest test: `ReportGenerator.tsx` handles download flow | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Data privacy compliance check (no PII in exported reports without authorization) | |
| [ ] | Large dataset performance test (10k+ records) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 8 — Continuous Improvement (Non‑Functional)

### Performance
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Profile Flutter app with DevTools — identify slow widget rebuilds | |
| [ ] | Optimize heavy screens with `const` constructors and `Selector` | |
| [ ] | Lazy‑load large assets (images, animations) | |
| [ ] | Enable code splitting for admin‑web (React lazy + Suspense) | |
| [ ] | Add performance benchmarks to CI | |

### Security
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Run `bandit` scan on Python backend — fix all HIGH severity findings | |
| [ ] | Run `dart pub audit` on Flutter project — fix vulnerabilities | |
| [ ] | Add secret scanning step to CI (e.g., `gitleaks`) | |
| [ ] | Add dependency vulnerability scanning to CI (`npm audit`, `pip-audit`) | |
| [ ] | Review and rotate all API keys and secrets | |

### Accessibility (Continuous)
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add automated a11y test step to CI for Flutter | |
| [ ] | Add `axe-core` accessibility testing for admin‑web | |
| [ ] | Quarterly manual accessibility audit | |

### Observability
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add custom Sentry tags for admin actions | |
| [ ] | Configure Sentry release tracking for Flutter APK versions | |
| [ ] | Set up Sentry alerts for error rate spikes | |
| [ ] | Add structured logging to backend (JSON format) | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | All performance targets met | |
| [ ] | All HIGH severity security findings resolved | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 9 — Emergency SOS Panic Button

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design SOS button UX: large red button on home screen, long‑press to activate | |
| [ ] | Define SOS activation flow: 3‑second hold → countdown → auto‑alert | |
| [ ] | Define SOS payload: user location, timestamp, battery %, profile link | |
| [ ] | Design SOS active screen (pulsing animation, cancel option within 10s) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/sos.py` — router file | |
| [ ] | Add `POST /api/v1/sos/trigger` — accepts lat/lon, creates SOS event, fans out notifications | |
| [ ] | Add `POST /api/v1/sos/cancel` — cancels SOS within grace period, notifies contacts "false alarm" | |
| [ ] | Add `GET /api/v1/sos/active` — returns current active SOS status for user | |
| [ ] | Create `backend/app/models/sos_event.py` — SOS event model (`id`, `user_id`, `lat`, `lon`, `status`, `triggered_at`, `resolved_at`) | |
| [ ] | Create Alembic migration for `sos_events` table | |
| [ ] | Integrate with existing `notification_service.py` — SMS + WhatsApp + FCM to all emergency contacts | |
| [ ] | Include Google Maps link to SOS location in notification message | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/sos/presentation/sos_button_widget.dart` — large floating SOS button | |
| [ ] | Implement long‑press (3s) activation with haptic feedback and countdown overlay | |
| [ ] | Create `lib/features/sos/presentation/sos_active_screen.dart` — pulsing animation, cancel button, live timer | |
| [ ] | Create `lib/features/sos/data/sos_repository.dart` — API calls for trigger/cancel | |
| [ ] | Create `lib/features/sos/domain/sos_provider.dart` — Riverpod state | |
| [ ] | Capture current GPS location using `geolocator` on trigger | |
| [ ] | Play alarm sound on activation using `audioplayers` | |
| [ ] | Add SOS button to `profile_home_screen.dart` (always visible) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: SOS trigger creates event and sends notifications | |
| [ ] | Backend unit test: SOS cancel within grace period marks event as cancelled | |
| [ ] | Backend unit test: SOS cancel after grace period returns error | |
| [ ] | Widget test: long‑press activates countdown, short tap does nothing | |
| [ ] | Widget test: cancel button stops SOS within window | |
| [ ] | Integration test: full SOS flow → trigger → notify → cancel | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | UX review: accidental activation prevention verified | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 10 — NFC Medical Tag Support

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define NFC tag data format: NDEF record containing `https://goldenhr.pages.dev/p/{uid}` | |
| [ ] | Design NFC write flow UI (place tag on phone, confirm write) | |
| [ ] | Identify compatible NFC tag types (NTAG213/215, budget ~₹10–30 per tag) | |
| [ ] | Design physical use cases: wristband, wallet card, keychain, helmet sticker | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `nfc_manager` dependency to `pubspec.yaml` | |
| [ ] | Create `lib/features/nfc/data/nfc_service.dart` — read/write NFC tags | |
| [ ] | Create `lib/features/nfc/presentation/nfc_write_screen.dart` — write QR URL to NFC tag | |
| [ ] | Add NFC write confirmation dialog with animation | |
| [ ] | Create `lib/features/nfc/presentation/nfc_read_screen.dart` — read and verify tag links to correct profile | |
| [ ] | Add "Write NFC Tag" button to QR display screen | |
| [ ] | Handle NFC not available / not enabled gracefully | |
| [ ] | Add NFC permission to `AndroidManifest.xml` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Unit test: NFC service formats NDEF record correctly | |
| [ ] | Widget test: write screen handles success and error states | |
| [ ] | Integration test: write tag → read tag → URL matches profile QR UID | |
| [ ] | Manual test on physical NFC tag and Android device | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 11 — Medication Reminders

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define reminder model: linked to existing `MedicationItem`, adds `reminder_times` (list of `TimeOfDay`) | |
| [ ] | Design reminder creation UI (time picker, repeat days, snooze options) | |
| [ ] | Design notification style (persistent, with "Taken" and "Snooze" actions) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/medication_reminder.py` — model (`id`, `user_id`, `medication_name`, `times`, `days`, `is_active`) | |
| [ ] | Create Alembic migration for `medication_reminders` table | |
| [ ] | Add `GET /api/v1/reminders` — list reminders for user | |
| [ ] | Add `POST /api/v1/reminders` — create reminder | |
| [ ] | Add `PUT /api/v1/reminders/{id}` — update reminder | |
| [ ] | Add `DELETE /api/v1/reminders/{id}` — delete reminder | |
| [ ] | Add `POST /api/v1/reminders/{id}/log` — log that medication was taken (adherence tracking) | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `flutter_local_notifications` and `timezone` dependencies | |
| [ ] | Create `lib/features/reminders/data/reminder_models.dart` | |
| [ ] | Create `lib/features/reminders/data/reminder_repository.dart` | |
| [ ] | Create `lib/features/reminders/domain/reminder_provider.dart` | |
| [ ] | Create `lib/features/reminders/presentation/reminders_screen.dart` — list of active reminders | |
| [ ] | Create `lib/features/reminders/presentation/add_reminder_screen.dart` — time picker, day selector | |
| [ ] | Schedule local notifications using `flutter_local_notifications` | |
| [ ] | Add "Taken" and "Snooze 15min" notification actions | |
| [ ] | Log adherence when "Taken" is pressed | |
| [ ] | Add "Reminders" entry to bottom navigation or profile screen | |
| [ ] | Link reminders to existing medications from profile wizard | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: reminder CRUD operations | |
| [ ] | Backend unit test: adherence log records timestamp | |
| [ ] | Widget test: reminder creation form validates inputs | |
| [ ] | Widget test: reminder list displays correct times and medications | |
| [ ] | Integration test: create reminder → notification fires at scheduled time | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | UX review: reminder notification is clear and actionable | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 12 — Family Dashboard (Shared Access)

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define sharing model: patient invites family member via phone/email → member sees read‑only profile + scan alerts | |
| [ ] | Design invitation flow UI (share link / QR invite, accept/decline) | |
| [ ] | Design family dashboard UI (patient's vitals, recent scans, location if shared) | |
| [ ] | Define permission levels: `viewer` (see profile), `guardian` (see profile + scan history + get SOS alerts) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/family_link.py` — model (`id`, `patient_id`, `member_id`, `role`, `status`, `invited_at`, `accepted_at`) | |
| [ ] | Create Alembic migration for `family_links` table | |
| [ ] | Add `POST /api/v1/family/invite` — patient sends invite | |
| [ ] | Add `POST /api/v1/family/accept/{invite_id}` — member accepts | |
| [ ] | Add `GET /api/v1/family/members` — list linked family members (for patient) | |
| [ ] | Add `GET /api/v1/family/patients` — list patients I'm linked to (for family member) | |
| [ ] | Add `GET /api/v1/family/patient/{patient_id}/profile` — read‑only profile view | |
| [ ] | Add `DELETE /api/v1/family/link/{id}` — revoke access | |
| [ ] | Extend notification pipeline: on QR scan, also notify `guardian` role family members | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/family/data/family_models.dart` | |
| [ ] | Create `lib/features/family/data/family_repository.dart` | |
| [ ] | Create `lib/features/family/domain/family_provider.dart` | |
| [ ] | Create `lib/features/family/presentation/family_members_screen.dart` — manage linked members | |
| [ ] | Create `lib/features/family/presentation/invite_screen.dart` — send invitation | |
| [ ] | Create `lib/features/family/presentation/family_dashboard_screen.dart` — view linked patient's data | |
| [ ] | Add route for family screens in `app_router.dart` | |
| [ ] | Add "Family" entry to bottom navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: invite creates pending family link | |
| [ ] | Backend unit test: accept changes status and grants read access | |
| [ ] | Backend unit test: family member can read patient profile but not modify | |
| [ ] | Backend unit test: revoke removes access | |
| [ ] | Backend unit test: guardian receives notification on QR scan | |
| [ ] | Widget test: family members screen lists linked members | |
| [ ] | Widget test: family dashboard displays patient info read‑only | |
| [ ] | Integration test: invite → accept → view profile → revoke | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Privacy review: family access respects patient's privacy toggle settings | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 13 — Nearby Hospitals & Blood Banks Finder

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define data source: Google Places API (`hospital`, `pharmacy`, `blood_bank` types) | |
| [ ] | Design nearby screen UI: map view + list view toggle, distance sorting | |
| [ ] | Design detail card: name, address, phone, directions button, open hours | |
| [ ] | Define search radius (default 5 km, adjustable) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/nearby.py` — router file | |
| [ ] | Add `GET /api/v1/nearby/hospitals?lat=&lon=&radius=` — proxies Google Places API, caches results in Redis (TTL: 1 hour) | |
| [ ] | Add `GET /api/v1/nearby/blood-banks?lat=&lon=&radius=` | |
| [ ] | Add `GET /api/v1/nearby/pharmacies?lat=&lon=&radius=` | |
| [ ] | Add `GOOGLE_PLACES_API_KEY` to config and `.env.example` | |
| [ ] | Implement Redis caching to reduce API costs | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/nearby/data/nearby_models.dart` — `NearbyPlace` model | |
| [ ] | Create `lib/features/nearby/data/nearby_repository.dart` | |
| [ ] | Create `lib/features/nearby/domain/nearby_provider.dart` | |
| [ ] | Create `lib/features/nearby/presentation/nearby_screen.dart` — map with markers + bottom sheet list | |
| [ ] | Create `lib/features/nearby/presentation/place_detail_card.dart` — name, distance, call, directions | |
| [ ] | Add category tabs: Hospitals, Blood Banks, Pharmacies | |
| [ ] | Integrate "Get Directions" button using `url_launcher` to open Google Maps | |
| [ ] | Add "Nearby" entry to bottom navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: nearby endpoint returns places sorted by distance | |
| [ ] | Backend unit test: Redis cache returns cached results within TTL | |
| [ ] | Widget test: nearby screen renders map and list | |
| [ ] | Widget test: category tabs filter results correctly | |
| [ ] | Integration test: fetch nearby hospitals → display on map → tap for directions | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | API cost review (Google Places pricing) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 14 — Medical History Timeline

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define timeline event types: profile update, document upload, scan event, SOS trigger, medication change | |
| [ ] | Design timeline UI: vertical chronological list with icons per event type | |
| [ ] | Define data aggregation: pull from existing `profiles`, `documents`, `scan_events` tables | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/timeline.py` — router file | |
| [ ] | Add `GET /api/v1/timeline?page=&per_page=` — aggregates events from all sources, sorted by date descending | |
| [ ] | Create `backend/app/services/timeline_service.py` — merges and sorts events from profile changes, documents, scans | |
| [ ] | Add event type enum: `PROFILE_UPDATE`, `DOCUMENT_UPLOAD`, `QR_SCAN`, `SOS_TRIGGER`, `MEDICATION_CHANGE` | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/timeline/data/timeline_models.dart` — `TimelineEvent` model | |
| [ ] | Create `lib/features/timeline/data/timeline_repository.dart` | |
| [ ] | Create `lib/features/timeline/domain/timeline_provider.dart` | |
| [ ] | Create `lib/features/timeline/presentation/timeline_screen.dart` — vertical list with date separators | |
| [ ] | Add event type icons: 🩺 profile, 📄 document, 📱 scan, 🚨 SOS, 💊 medication | |
| [ ] | Add tap‑to‑expand detail for each event | |
| [ ] | Add filter chips: filter by event type | |
| [ ] | Add route and navigation entry | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: timeline aggregates events from all sources | |
| [ ] | Backend unit test: pagination returns correct page size | |
| [ ] | Backend unit test: events are sorted by date descending | |
| [ ] | Widget test: timeline screen renders events with correct icons | |
| [ ] | Widget test: filter chips filter events correctly | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 15 — Insurance & Emergency ID Card

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define insurance model: `provider_name`, `policy_number`, `group_number`, `valid_until`, `holder_name` | |
| [ ] | Design insurance form UI (add/edit insurance details) | |
| [ ] | Design digital emergency ID card: wallet-style card showing name, blood group, allergies, insurance, emergency contacts | |
| [ ] | Define export options: save as PNG, add to Google Wallet (future) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Extend `backend/app/models/profile.py` — add `insurance_info` JSON column | |
| [ ] | Create Alembic migration for insurance field | |
| [ ] | Update `PUT /profile/me` to accept insurance data | |
| [ ] | Update `GET /qr/public/{uid}` — include insurance info if patient has `show_insurance` privacy toggle enabled | |
| [ ] | Add `show_insurance` privacy toggle to profile model | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/insurance/data/insurance_models.dart` | |
| [ ] | Create `lib/features/insurance/presentation/insurance_form_screen.dart` — add/edit insurance | |
| [ ] | Add insurance step to profile wizard (optional step 6) | |
| [ ] | Create `lib/features/id_card/presentation/emergency_id_card_screen.dart` — wallet‑style card | |
| [ ] | Add "Download ID Card" button — generates PNG using `screenshot` package | |
| [ ] | Add share functionality for ID card image | |
| [ ] | Add `show_insurance` toggle to `privacy_settings_screen.dart` | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: insurance data saves and retrieves correctly | |
| [ ] | Backend unit test: public endpoint respects `show_insurance` toggle | |
| [ ] | Widget test: insurance form validates required fields | |
| [ ] | Widget test: emergency ID card renders all information correctly | |
| [ ] | Widget test: download produces valid PNG image | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Privacy review: insurance data visibility controlled by patient | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 16 — Profile Photo Upload & QR Personalization

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define image constraints: max 2 MB, JPEG/PNG, 512×512 crop | |
| [ ] | Design photo upload UX: camera / gallery picker, crop circle, preview | |
| [ ] | Design personalized QR card: patient photo + name + blood group around QR code | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `POST /api/v1/profile/photo` — upload photo, store in object storage, update `photo_url` | |
| [ ] | Add `DELETE /api/v1/profile/photo` — remove photo | |
| [ ] | Validate file size (<2 MB) and MIME type (JPEG, PNG) | |
| [ ] | Generate thumbnail (128×128) for list views | |
| [ ] | Update responder web to show photo if `show_photo` is true | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `image_picker` and `image_cropper` dependencies (already partially present) | |
| [ ] | Create photo upload flow: pick image → crop to circle → upload → update profile | |
| [ ] | Display photo on `profile_home_screen.dart` and `edit_profile_screen.dart` | |
| [ ] | Create personalized QR card widget: photo + name + blood group + QR code in a styled card | |
| [ ] | Add "Download QR Card" button — generates PNG of the personalized card | |
| [ ] | Add `show_photo` toggle integration (already exists in profile model) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: photo upload stores file and updates `photo_url` | |
| [ ] | Backend unit test: file size and MIME validation rejects invalid uploads | |
| [ ] | Backend unit test: delete removes file from storage | |
| [ ] | Widget test: photo picker and crop flow works correctly | |
| [ ] | Widget test: personalized QR card renders with photo and details | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Storage costs reviewed | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 17 — In‑App Notification Centre

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define notification categories: SOS alerts, scan events, medication reminders, system updates, profile nudges | |
| [ ] | Design notification centre UI: chronological list with category icons, read/unread state | |
| [ ] | Define notification storage: local SQLite + sync with backend | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/in_app_notification.py` — model (`id`, `user_id`, `type`, `title`, `body`, `data`, `read`, `created_at`) | |
| [ ] | Create Alembic migration for `in_app_notifications` table | |
| [ ] | Add `GET /api/v1/notifications/inbox?page=&unread_only=` — paginated notifications | |
| [ ] | Add `PATCH /api/v1/notifications/inbox/{id}/read` — mark as read | |
| [ ] | Add `POST /api/v1/notifications/inbox/read-all` — mark all as read | |
| [ ] | Integrate: create in‑app notification whenever push notification is sent | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `lib/features/notifications/presentation/notification_centre_screen.dart` — full notification list | |
| [ ] | Add unread count badge on notification bell icon in home screen AppBar | |
| [ ] | Add pull‑to‑refresh and infinite scroll pagination | |
| [ ] | Add swipe‑to‑dismiss (mark as read) gesture | |
| [ ] | Add tap handler: navigate to relevant screen based on notification type | |
| [ ] | Cache notifications locally using `sqflite` for offline access | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: inbox returns notifications sorted by date | |
| [ ] | Backend unit test: mark‑as‑read updates status | |
| [ ] | Backend unit test: notification created on push send | |
| [ ] | Widget test: notification centre renders list with read/unread styling | |
| [ ] | Widget test: unread badge shows correct count | |
| [ ] | Widget test: swipe‑to‑dismiss marks notification as read | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 18 — Profile Completion Nudges & Periodic Reminders

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define nudge triggers: profile score < 80%, no login in 30 days, medications not updated in 90 days | |
| [ ] | Design nudge notification content (friendly, non‑intrusive) | |
| [ ] | Define "Is your info up to date?" reminder schedule (every 90 days) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/tasks/nudge_tasks.py` — Celery periodic task (runs daily) | |
| [ ] | Implement profile completion check: push notification if score < 80% and last nudge > 7 days ago | |
| [ ] | Implement staleness check: push "Is your info up to date?" if profile not updated in 90 days | |
| [ ] | Implement re‑engagement: push if user hasn't opened app in 30 days | |
| [ ] | Add `last_nudge_at` field to profile model | |
| [ ] | Create Alembic migration for `last_nudge_at` column | |
| [ ] | Add Celery Beat schedule configuration | |

### Flutter Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Handle nudge push notifications — deep link to profile edit screen | |
| [ ] | Show in‑app banner on home screen if profile score < 80%: "Complete your profile to help responders save your life" | |
| [ ] | Add completion progress bar to profile home screen (already partially exists) | |
| [ ] | Dismiss banner for 7 days after user taps "Later" | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: nudge task identifies incomplete profiles | |
| [ ] | Backend unit test: nudge respects cooldown period (no duplicate nudges within 7 days) | |
| [ ] | Backend unit test: staleness check identifies outdated profiles | |
| [ ] | Widget test: in‑app banner appears when profile score < 80% | |
| [ ] | Widget test: banner dismisses and respects cooldown | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Notification frequency reviewed (not spammy) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 📈 Next Features Progress Summary

| Phase | Total | Done | Remaining |
|-------|-------|------|-----------|
| Phase 1 — Wearable Integration | 22 | 0 | 22 |
| Phase 2 — AI‑Powered Triage | 26 | 0 | 26 |
| Phase 3 — Community Forum | 33 | 0 | 33 |
| Phase 4 — Offline Sync Mechanism | 18 | 0 | 18 |
| Phase 5 — Exportable Health Report (PDF) | 19 | 0 | 19 |
| Phase 6 — Enterprise Multi‑Tenant Mode | 24 | 0 | 24 |
| Phase 7 — Advanced Reporting & Export | 21 | 0 | 21 |
| Phase 8 — Continuous Improvement | 19 | 0 | 19 |
| Phase 9 — Emergency SOS Panic Button | 26 | 0 | 26 |
| Phase 10 — NFC Medical Tag Support | 16 | 0 | 16 |
| Phase 11 — Medication Reminders | 27 | 0 | 27 |
| Phase 12 — Family Dashboard (Shared Access) | 30 | 0 | 30 |
| Phase 13 — Nearby Hospitals & Blood Banks | 22 | 0 | 22 |
| Phase 14 — Medical History Timeline | 17 | 0 | 17 |
| Phase 15 — Insurance & Emergency ID Card | 18 | 0 | 18 |
| Phase 16 — Profile Photo & QR Personalization | 16 | 0 | 16 |
| Phase 17 — In‑App Notification Centre | 18 | 0 | 18 |
| Phase 18 — Profile Nudges & Reminders | 17 | 0 | 17 |
| **TOTAL** | **369** | **0** | **369** |

---

*Last updated: 2026-11-14 | Branch: `next-updates`*

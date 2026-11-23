# ✅ Admin Panel — Implementation Checklist

> **How to use this file:**
> - Mark items as done: change `[ ]` → `[x]`
> - Add the completion date next to each item when done: `[x] Feature Name ✦ 2026-11-XX`
> - Add notes or blockers inline using `<!-- note: ... -->`
> - Commit this file after every working session so progress is always tracked

*Branch:* `next-updates`

---

## 🏗️ Phase 1 — Project Setup & Scaffolding

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define admin-web folder structure (`src/pages`, `src/components`, `src/services`, `src/store`) | |
| [ ] | Select UI library: MUI (Material UI) | |
| [ ] | Select state management: Zustand | |
| [ ] | List all required npm dependencies | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Run `npx create-vite@latest admin-web --template react-ts` inside `apps/` | |
| [ ] | Install core dependencies: `@mui/material`, `@emotion/react`, `@emotion/styled`, `axios`, `react-router-dom`, `zustand` | |
| [ ] | Install chart dependencies: `recharts`, `react-leaflet` | |
| [ ] | Create `apps/admin-web/Dockerfile` (multi-stage: node builder → nginx) | |
| [ ] | Configure `vite.config.ts` (base path, proxy for backend API) | |
| [ ] | Create `src/App.tsx` with React Router layout (sidebar + main content) | |
| [ ] | Create `src/main.tsx` entry point | |
| [ ] | Create `src/layouts/AdminLayout.tsx` — sidebar nav, header, content area | |
| [ ] | Create `src/theme/muiTheme.ts` — custom MUI theme matching Golden Hour branding | |
| [ ] | Add ESLint + Prettier config | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Dev server starts without errors (`npm run dev`) | |
| [ ] | ESLint lint passes with zero errors | |
| [ ] | Production build completes (`npm run build`) | |
| [ ] | Docker image builds and runs correctly | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Code review — folder structure and conventions approved | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 2 — Authentication & RBAC

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define admin roles: `SUPER_ADMIN`, `MANAGER`, `VIEWER` | |
| [ ] | Define JWT claims: `user_id`, `email`, `role`, `exp` | |
| [ ] | Design login page UI mockup | |
| [ ] | Define permission matrix (which role can access which endpoints) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/admin/` directory | |
| [ ] | Create `backend/app/api/v1/admin/__init__.py` | |
| [ ] | Create `backend/app/api/v1/admin/auth.py` — `POST /admin/auth/login` (email + password → JWT) | |
| [ ] | Create `backend/app/api/v1/admin/auth.py` — `POST /admin/auth/refresh` (refresh token rotation) | |
| [ ] | Create `backend/app/api/v1/admin/auth.py` — `POST /admin/auth/logout` (revoke token) | |
| [ ] | Create `backend/app/models/admin_role.py` — Role model (`id`, `name`, `permissions`) | |
| [ ] | Extend `backend/app/middleware/auth_middleware.py` with `require_admin_role()` dependency | |
| [ ] | Create Alembic migration for admin roles table and seed default roles | |
| [ ] | Register admin router in `main.py` under `/admin` prefix | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Login.tsx` — email + password form, error handling | |
| [ ] | Create `src/services/authService.ts` — login, logout, refresh API calls | |
| [ ] | Create `src/store/authStore.ts` — Zustand store for token + user info | |
| [ ] | Create `src/components/RequireRole.tsx` — HOC that checks role and redirects | |
| [ ] | Create `src/components/ProtectedRoute.tsx` — wraps routes requiring auth | |
| [ ] | Implement auto‑redirect: unauthenticated → login page | |
| [ ] | Implement token refresh on 401 response (Axios interceptor) | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: login with valid credentials returns JWT | |
| [ ] | Backend unit test: login with invalid credentials returns 401 | |
| [ ] | Backend unit test: `require_admin_role('SUPER_ADMIN')` blocks `VIEWER` role | |
| [ ] | Backend unit test: expired token returns 401 | |
| [ ] | Frontend Jest test: `Login.tsx` renders form and handles submit | |
| [ ] | Frontend Jest test: `RequireRole` redirects unauthorized users | |
| [ ] | Frontend Jest test: Axios interceptor refreshes token on 401 | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Security audit: token storage, expiry, refresh flow | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 3 — User Management

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design user list page wireframe (table with search, filters, pagination) | |
| [ ] | Design user edit modal wireframe (role dropdown, status toggle) | |
| [ ] | Define API contract for user CRUD | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/admin/users.py` — `GET /admin/users` (paginated list with search) | |
| [ ] | Add `GET /admin/users/{id}` — single user detail with profile + contacts | |
| [ ] | Add `PATCH /admin/users/{id}` — update role, status (activate/deactivate) | |
| [ ] | Add `DELETE /admin/users/{id}` — soft‑delete user (DPDPA compliance) | |
| [ ] | Add `GET /admin/users/stats` — total users, active, new this week | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Users/UserList.tsx` — MUI DataGrid with search, sort, pagination | |
| [ ] | Create `src/pages/Users/UserDetail.tsx` — profile summary, emergency contacts, documents | |
| [ ] | Create `src/components/UserEditModal.tsx` — edit role, toggle status | |
| [ ] | Create `src/services/userService.ts` — API calls for user CRUD | |
| [ ] | Add "Users" entry to sidebar navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: `GET /admin/users` returns paginated results | |
| [ ] | Backend unit test: `PATCH /admin/users/{id}` updates role correctly | |
| [ ] | Backend unit test: only `SUPER_ADMIN` and `MANAGER` can access user endpoints | |
| [ ] | Frontend Jest test: `UserList.tsx` renders table with mock data | |
| [ ] | Frontend Jest test: `UserEditModal.tsx` submits form correctly | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | UX review of user management flow | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 4 — Document & QR Management

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design document management page (table with type, user, date, actions) | |
| [ ] | Design QR management page (list of QR codes with status, scan count) | |
| [ ] | Define upload flow (drag‑and‑drop, max file size, allowed types) | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/admin/documents.py` — `GET /admin/documents` (all users' docs, paginated) | |
| [ ] | Add `GET /admin/documents/{id}` — document detail with download URL | |
| [ ] | Add `DELETE /admin/documents/{id}` — remove document from storage + DB | |
| [ ] | Create `backend/app/api/v1/admin/qr.py` — `GET /admin/qr` (all QR codes, scan counts) | |
| [ ] | Add `POST /admin/qr/{id}/revoke` — invalidate a QR code | |
| [ ] | Add `POST /admin/qr/{id}/regenerate` — generate new UID for user | |
| [ ] | Add `GET /admin/qr/{id}/stats` — scan count, last scanned, locations | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Documents/DocumentList.tsx` — table with filters (user, type, date) | |
| [ ] | Create `src/pages/Documents/DocumentDetail.tsx` — preview + download | |
| [ ] | Create `src/pages/QR/QrManager.tsx` — QR list with status badges, scan counts | |
| [ ] | Create `src/pages/QR/QrDetail.tsx` — QR image, scan history, revoke/regenerate buttons | |
| [ ] | Add "Documents" and "QR Codes" entries to sidebar navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: admin can list all documents across users | |
| [ ] | Backend unit test: QR revoke invalidates public endpoint | |
| [ ] | Backend unit test: QR regenerate creates new UID | |
| [ ] | Frontend Jest test: `DocumentList.tsx` renders with mock data | |
| [ ] | Frontend Jest test: `QrManager.tsx` shows status badges correctly | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Storage security review (no unauthorized access to files) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 5 — Notification Engine

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Design notification composer UI (title, body, recipient selector, category) | |
| [ ] | Define notification delivery log schema | |
| [ ] | Define rate limits for admin‑sent notifications | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/admin/notifications.py` — `POST /admin/notifications/push` | |
| [ ] | Add `GET /admin/notifications/history` — all sent notifications with delivery status | |
| [ ] | Add `GET /admin/notifications/{id}` — single notification detail | |
| [ ] | Integrate with existing `notification_service.py` for FCM dispatch | |
| [ ] | Log each admin notification send in `admin_audit` table | |
| [ ] | Add rate limiting: max 100 notifications per hour per admin | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Notifications/NotificationComposer.tsx` — form with title, body, recipient multi‑select | |
| [ ] | Create `src/pages/Notifications/NotificationHistory.tsx` — table with delivery status | |
| [ ] | Create `src/services/notificationService.ts` — API calls | |
| [ ] | Add "Notifications" entry to sidebar navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: push endpoint validates input (title required, at least one target) | |
| [ ] | Backend unit test: push endpoint calls FCM service correctly | |
| [ ] | Backend unit test: rate limiter blocks excess requests | |
| [ ] | Frontend Jest test: `NotificationComposer.tsx` validates form | |
| [ ] | End‑to‑end test: compose → send → verify delivery log entry | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Audit logging verified | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 6 — Analytics Dashboard

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Identify key metrics: daily SOS count, active users, new registrations, top scanned QRs | |
| [ ] | Choose chart types: line chart (SOS over time), bar chart (registrations), heat map (scan locations) | |
| [ ] | Design dashboard layout wireframe | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/api/v1/admin/analytics.py` — `GET /admin/analytics/overview` (summary stats) | |
| [ ] | Add `GET /admin/analytics/sos-stats` — daily SOS counts (last 30 days) | |
| [ ] | Add `GET /admin/analytics/user-stats` — registration trend, active users | |
| [ ] | Add `GET /admin/analytics/scan-heatmap` — scan locations for heat map | |
| [ ] | Add Redis caching for aggregated stats (TTL: 5 min) | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Dashboard/Dashboard.tsx` — overview cards (total users, SOS today, active QRs) | |
| [ ] | Add SOS trend line chart using `recharts` | |
| [ ] | Add user registration bar chart using `recharts` | |
| [ ] | Add scan location heat map using `react-leaflet` | |
| [ ] | Create `src/services/analyticsService.ts` — API calls | |
| [ ] | Set dashboard as the default landing page after login | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: analytics endpoints return correct aggregated data | |
| [ ] | Backend unit test: Redis cache returns cached data within TTL | |
| [ ] | Frontend Jest test: `Dashboard.tsx` renders charts with mock data | |
| [ ] | Frontend Jest test: overview cards display correct numbers | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Metric accuracy verified against raw DB queries | |
| [ ] | Privacy compliance check (no PII in analytics) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 7 — System Settings & Feature Flags

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define configurable settings: `MAINTENANCE_MODE`, `MAX_CONTACTS`, `ENABLE_AI_ASSIST`, `ENABLE_LOCATION_SHARING` | |
| [ ] | Design settings panel UI (toggles, text inputs, save button) | |
| [ ] | Restrict access to `SUPER_ADMIN` only | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/system_setting.py` — key‑value model (key, value, type) | |
| [ ] | Create Alembic migration for `system_settings` table with seed data | |
| [ ] | Create `backend/app/api/v1/admin/settings.py` — `GET /admin/settings` (all settings) | |
| [ ] | Add `PUT /admin/settings/{key}` — update a setting value | |
| [ ] | Add `require_admin_role('SUPER_ADMIN')` dependency on settings endpoints | |
| [ ] | Create `backend/app/services/feature_flags.py` — helper to check flags in business logic | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/Settings/SettingsPanel.tsx` — renders toggles for booleans, text inputs for strings | |
| [ ] | Create `src/services/settingsService.ts` — API calls | |
| [ ] | Add "Settings" entry to sidebar (visible only to `SUPER_ADMIN`) | |
| [ ] | Add save confirmation dialog | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: `GET /admin/settings` returns all settings | |
| [ ] | Backend unit test: `PUT /admin/settings/{key}` updates correctly | |
| [ ] | Backend unit test: non‑SUPER_ADMIN gets 403 | |
| [ ] | Backend unit test: `feature_flags.py` returns correct boolean | |
| [ ] | Frontend Jest test: `SettingsPanel.tsx` renders toggles and handles save | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Verify no secrets exposed in settings API response | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 8 — Audit Log

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define audit log schema: `id`, `admin_user_id`, `action`, `resource`, `details` (JSON), `ip_address`, `timestamp` | |
| [ ] | Define logged actions: login, user update, document delete, QR revoke, notification send, setting change | |
| [ ] | Design audit log table UI with filters and CSV export | |

### Backend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `backend/app/models/admin_audit.py` — AuditLog model | |
| [ ] | Create Alembic migration for `admin_audit_log` table | |
| [ ] | Create `backend/app/services/audit_service.py` — `log_action(user_id, action, resource, details)` | |
| [ ] | Integrate `audit_service.log_action()` into all admin endpoints | |
| [ ] | Create `backend/app/api/v1/admin/audit.py` — `GET /admin/audit` (paginated, filterable by date, action, user) | |
| [ ] | Add `GET /admin/audit/export?format=csv` — download as CSV | |

### Frontend Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `src/pages/AuditLog/AuditLogTable.tsx` — table with date range picker, action filter, user filter | |
| [ ] | Add "Export CSV" button that triggers download | |
| [ ] | Create `src/services/auditService.ts` — API calls | |
| [ ] | Add "Audit Log" entry to sidebar navigation | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Backend unit test: `audit_service.log_action()` creates DB record | |
| [ ] | Backend unit test: `GET /admin/audit` filters by date range correctly | |
| [ ] | Backend unit test: CSV export contains correct columns and data | |
| [ ] | Frontend Jest test: `AuditLogTable.tsx` renders logs and handles filter changes | |
| [ ] | Integration test: admin performs action → audit log entry appears | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Verify audit logs are immutable (no update/delete endpoints) | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 9 — Admin Panel CI & Deployment

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Define admin‑web CI jobs: lint, test, build, docker | |
| [ ] | Choose deployment target: Docker container behind Nginx / Caddy | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Add `admin-web-lint` job to `.github/workflows/ci.yml` — ESLint | |
| [ ] | Add `admin-web-test` job — Jest test suite | |
| [ ] | Add `admin-web-build` job — `npm run build`, upload `dist/` as artifact | |
| [ ] | Add `admin-web-docker` job — build + push Docker image to GHCR | |
| [ ] | Add admin‑web service to `docker-compose.yml` (port 3000 → nginx 80) | |
| [ ] | Configure Caddy / Nginx reverse proxy for `/admin` path | |
| [ ] | Add environment variables to `.env.example` for admin JWT secret, DB URL | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | CI pipeline runs all admin‑web jobs successfully | |
| [ ] | Docker image builds and serves static files correctly | |
| [ ] | Admin UI accessible at configured URL | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Deployment configuration reviewed | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 🏗️ Phase 10 — Admin Panel Documentation & E2E Testing

### Design
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Outline `docs/ADMIN_PANEL.md` structure | |
| [ ] | Define Cypress E2E test scenarios | |

### Development
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Create `docs/ADMIN_PANEL.md` — architecture overview, setup steps, env vars, usage guide | |
| [ ] | Enable FastAPI auto‑docs at `/admin/docs` (Swagger) | |
| [ ] | Install Cypress in admin‑web project | |
| [ ] | Write Cypress test: admin login flow | |
| [ ] | Write Cypress test: user list → edit user → verify update | |
| [ ] | Write Cypress test: compose notification → send → verify history | |
| [ ] | Write Cypress test: audit log appears after admin action | |
| [ ] | Add Cypress to CI pipeline | |

### Testing
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | All Cypress E2E tests pass | |
| [ ] | Swagger docs render correctly at `/admin/docs` | |
| [ ] | `ADMIN_PANEL.md` reviewed for completeness | |

### Review & Merge
| Status | Task | Completed On |
|--------|------|--------------|
| [ ] | Documentation review completed | |
| [ ] | Code review completed | |
| [ ] | Merged to `next-updates` branch | |
| [ ] | CI build passes | |

---

## 📈 Admin Panel Progress Summary

| Phase | Total | Done | Remaining |
|-------|-------|------|-----------|
| Phase 1 — Project Setup & Scaffolding | 18 | 0 | 18 |
| Phase 2 — Authentication & RBAC | 28 | 0 | 28 |
| Phase 3 — User Management | 19 | 0 | 19 |
| Phase 4 — Document & QR Management | 21 | 0 | 21 |
| Phase 5 — Notification Engine | 19 | 0 | 19 |
| Phase 6 — Analytics Dashboard | 19 | 0 | 19 |
| Phase 7 — System Settings & Feature Flags | 18 | 0 | 18 |
| Phase 8 — Audit Log | 19 | 0 | 19 |
| Phase 9 — CI & Deployment | 13 | 0 | 13 |
| Phase 10 — Documentation & E2E Testing | 14 | 0 | 14 |
| **TOTAL** | **188** | **0** | **188** |

---

*Last updated: 2026-11-14 | Branch: `next-updates`*

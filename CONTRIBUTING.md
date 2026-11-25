# Contributing to Golden Hour

Thank you for contributing to **Golden Hour**! To keep releases predictable, automated, and clean, this repository follows **Semantic Versioning (SemVer)** and the **Conventional Commits** specification.

---

## Commit Message Convention

All commit messages **must** follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format:

```text
<type>(<optional scope>): <short summary>

[optional body]

[optional footer(s)]
```

### Allowed Types & Release Impact

| Type | Purpose | Version Bump | Included in `CHANGELOG.md` |
| :--- | :--- | :--- | :--- |
| `feat` | A new feature for the user | **MINOR** (`x.Y.0`) | Yes (Features) |
| `fix` | A bug fix | **PATCH** (`x.y.Z`) | Yes (Bug Fixes) |
| `perf` | A performance improvement | **PATCH** (`x.y.Z`) | Yes (Performance Improvements) |
| `refactor` | Code change that neither fixes a bug nor adds a feature | **PATCH** (`x.y.Z`) | Yes (Code Refactoring) |
| `docs` | Documentation-only changes (`docs(README): ...` triggers patch) | None / **PATCH** (`README`) | Yes (Documentation) |
| `style` | Formatting, missing semicolons, etc. (no code change) | None | No |
| `test` | Adding or updating tests | None | No |
| `chore` | Build scripts, CI, or maintenance tasks | None | No |

### Breaking Changes

To trigger a **MAJOR** release (`X.0.0`), append `!` after the type/scope or include `BREAKING CHANGE:` in the commit footer:

```text
feat(api)!: switch QR payload schema to v2

BREAKING CHANGE: v1 unencrypted QR payloads are no longer accepted.
```

### Good Commit Examples

```text
feat(guides): add offline choking first-aid guide in Hindi
fix(radar): prevent duplicate geofence alert on reconnect
perf(qr): cache generated QR SVG in memory
docs(README): add Docker Compose troubleshooting section
chore(ci): update semantic-release plugins
```

---

## Versioning & Automated Releases

Golden Hour uses [`semantic-release`](https://semantic-release.gitbook.io/) configured in `release.config.js`:

1. **Development:** Work on feature branches and merge into `next-updates` (or open Pull Requests against `main`).
2. **Release Trigger:** On every push/merge to `main`, GitHub Actions runs the `semantic-release` job after all lint, test, and build checks pass.
3. **Automated Steps:**
   - Analyzes commits since the last Git tag (`v*`).
   - Computes the next SemVer version (`MAJOR.MINOR.PATCH`).
   - Runs `scripts/bump-version.mjs` to update `apps/mobile/pubspec.yaml` (incrementing the `+buildNumber`) and `backend/pyproject.toml`.
   - Updates `CHANGELOG.md`.
   - Commits the bumped files with `[skip ci]`, tags the release (`vX.Y.Z`), and publishes a GitHub Release with APK & AAB artifacts.

### Local Dry-Run Verification

To preview what `semantic-release` would release without pushing or tagging:

```bash
npm install
npm run release:dry-run
```

To test the version bump script without modifying files:

```bash
node scripts/bump-version.mjs 1.1.0 --dry-run
```

---

## Compliance Note

All contributions must preserve Golden Hour's **non-clinical emergency safety profile** positioning under India's **Digital Personal Data Protection Act (DPDPA) 2023**. Never introduce medical diagnosis, treatment, or clinical triage claims in UI copy, metadata, or documentation.


# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- Remove hardcoded `secret_key_base` and legacy `secret_token` from the
  repository; production secrets are now read from `SECRET_KEY_BASE` and
  `DATABASE_URL` environment variables.
- **Make production fail closed at boot.** `config/environments/production.rb`
  now raises when `SECRET_KEY_BASE` or `DATABASE_URL` is missing or blank, on
  every adapter, instead of deferring to a downstream framework error (or, for
  the secret key, to a fallback).
- Enable `protect_from_forgery with: :exception` (session-fixation hardening).
- **Fix a stored-XSS / reverse-tabnabbing path in the task list.** The index
  view rendered task names with `raw auto_link(...)`, which disabled escaping
  for the whole expression and emitted `target="_blank"` anchors with no `rel`.
  Names are now escaped, auto-linked with `rel="nofollow noopener noreferrer"`
  forced onto every generated anchor, and passed through a strict tag/attribute
  allowlist (`TasksHelper#linked_task_name`). There is no unescaped-markup path
  left in the app.
- **Stop mass-assignment of task ownership.** `:list_id` is no longer permitted
  on task update. Task scope comes from the nested route's parent list, and
  permitting `list_id` was the one write path that could move a task across that
  boundary while `create`/`update`/`destroy` all enforced it.
- **Validate `list_id` before it reaches the database.** The index view used to
  run `List.find_by(:id => params[:list_id])` itself, passing raw user input to
  the adapter (a non-integer value for an integer column raises a driver error).
  Selection is now resolved in `TasksController#index` and only accepts a plain
  positive integer.
- **Bound the JSON task feed.** `GET /tasks.json` serialised the entire tasks
  table — a full-table disclosure and an unbounded memory cost, reachable
  unauthenticated. It is now list-scoped and capped at
  `TasksController::MAX_JSON_TASKS` (200).
- **Bound stored input.** `Task#name` and `List#name` gain length caps matching
  their columns, plus whitespace normalisation (which also closes a whitespace
  bypass of the list-name uniqueness check).
- **Add response hardening headers on every response** via new
  `PreCogSecurity::SecurityHeaders` middleware (outermost in the stack, so
  static files and error responses are covered too): `Content-Security-Policy`,
  `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`,
  `X-XSS-Protection: 0`, `X-Permitted-Cross-Domain-Policies`.
- Broaden request-parameter redaction to cover secrets, tokens, API keys,
  cookies and authorization headers, not just `password`.
- Make the session cookie's `HttpOnly` and `Secure` flags explicit.
- Upgrade jQuery UI in the app layout from 1.8.13 (2012) to 1.13.2, moving off
  four published XSS issues (CVE-2015-9251, CVE-2016-7961, CVE-2020-11022,
  CVE-2020-11023) and onto the upstream CDN.
- **Purge committed secrets and stale dependencies.** Removed a scraped
  Netscape cookie jar containing live third-party session cookies
  (`article/article/cookies.txt`), the accompanying HTTrack download cache and
  log, and a 16 MB vendored `vendor/cache` of gems pinned to the unpatched
  Rails 4.2.0 set. `.gitignore` now blocks all of them from returning.
- `precog/precog-security/main.py` no longer hardcodes `debug=True`, which
  answered unhandled exceptions with a full traceback including source and
  local variable values (CWE-209).
- Add typed input validation to `TasksController#create`: malformed JSON and
  non-hash task parameters now return `400 Bad Request` instead of raising
  `500` errors.
- Scope task `update`/`destroy` lookups to the parent list so a task cannot be
  modified through a mismatched list id.
- Enable `config.force_ssl` in production.

### Fixed

- `TasksController#update` no longer renders a non-existent `edit` template on
  validation failure (was a `500`); it redirects with an alert and returns
  `422` for JSON clients.
- `ListsController#create` no longer raises a routing error when list
  validation fails; it redirects to the root with an alert.
- `TasksController#index` JSON payload is no longer double-encoded.
- The index view no longer raises `RecordNotFound` for a stale `list_id`
  parameter, no longer runs a database query from the view layer, and no longer
  emits broken JavaScript when the tab index is nil.
- Removed `todo/script/ci`, a dead EngineYard CI script that pinned Ruby 1.9.2
  and overwrote the hardened `config/database.yml` with interpolated plaintext
  credentials.
- Removed `todo/.travis.yml`, which targeted Ruby 1.9.3–2.2.0 and invoked a
  `rake travis` task the app does not define.
- Removed the orphaned `_todo_task.html.erb` partial and the unbounded
  `Task.where(done: false)` query that only existed to feed it.
- Deleted `Knight.zip`, a 2 MB duplicate of assets already in `precog/`.

### Added

- **Root-level build entry points.** `Makefile` (`install`, `prepare`, `test`,
  `lint`, `audit`, `check`, `run`, `clean`, `docker-*`) plus `.ruby-version`, so
  a fresh clone has one discoverable way to build and test the project without
  knowing that the application lives in a subdirectory.
- GitHub Actions CI (`.github/workflows/ci.yml`): test suite with an enforced
  coverage floor, RuboCop, a container-build gate, and an informational
  `bundler-audit` dependency scan on every push/PR.
- New `container` CI job that builds the `todo/` image, asserts no secret is
  baked into it, and asserts the app refuses to boot in production without
  `SECRET_KEY_BASE`.
- SimpleCov minimum-coverage enforcement (default 60%, overridable with
  `COVERAGE_MINIMUM`) as a documented ratchet.
- Integration tests covering the full create-list → add-task → complete →
  delete flow and cross-list isolation (`todo/test/integration/`).
- Request tests asserting the security headers on JSON, HTML and error
  responses (`todo/test/requests/`).
- Model tests for input length caps and whitespace normalisation; controller
  tests for `list_id` validation, the JSON cap and list scoping; helper tests
  for the XSS and reverse-tabnabbing fixes.
- Dependabot (`.github/dependabot.yml`) for bundler and GitHub Actions.
- `ARCHIVED.md` markers for `blog/`, `precog/`, `precog/blog/` and
  `precog/socify/`, documenting each as outside the build path and listing the
  EOL front-end pins that must not be reused.
- Health check endpoint `GET /health` returning JSON status including database
  connectivity.
- Structured JSON logging for production.
- Real behavioral tests for models, controllers, and helpers, plus SimpleCov
  coverage reporting.
- RuboCop configuration (Lint + Security families).
- `Dockerfile` and `docker-compose.yml` for the `todo/` app.
- `CHANGELOG.md`, `CONTRIBUTING.md`, `.env.example`, and full setup/run/test
  documentation in the README.

### Changed

- `todo/Gemfile`: Rails pinned to `~> 4.2.11` (final 4.2.x line with all
  backported security fixes); runtime gems pinned to versions compatible with
  Ruby 2.7 and Bundler 1.17.3 so a fresh clone installs and tests cleanly.
- `todo/Dockerfile`: excludes tests, lint config and vendored caches from the
  runtime image, cutting the build context substantially.
- README documents the actual project classification (Ruby on Rails, not
  infrastructure-as-code) and the quarantine status of every other directory.
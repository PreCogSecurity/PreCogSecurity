# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- Remove hardcoded `secret_key_base` and legacy `secret_token` from the
  repository; production secrets are now read from `SECRET_KEY_BASE` and
  `DATABASE_URL` environment variables and the app fails closed at boot when
  they are missing.
- Enable `protect_from_forgery with: :exception` (session-fixation hardening).
- Add typed input validation to `TasksController#create`: malformed JSON and
  non-hash task parameters now return `400 Bad Request` instead of raising
  `500` errors.
- Scope task `update`/`destroy` lookups to the parent list so a task cannot be
  modified through a mismatched list id.
- Enable `config.force_ssl` in production.
- Remove committed `node_modules` and vendored third-party JavaScript from the
  tree; front-end libraries are now referenced from pinned CDN URLs.

### Fixed

- `TasksController#update` no longer renders a non-existent `edit` template on
  validation failure (was a `500`); it redirects with an alert and returns
  `422` for JSON clients.
- `ListsController#create` no longer raises a routing error when list
  validation fails; it redirects to the root with an alert.
- `TasksController#index` JSON payload is no longer double-encoded.
- The index view no longer raises `RecordNotFound` for a stale `list_id`
  parameter and no longer emits broken JavaScript when the tab index is nil.

### Added

- GitHub Actions CI (`.github/workflows/ci.yml`): test suite, RuboCop, and an
  informational `bundler-audit` dependency scan on every push/PR.
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
  Ruby 2.7 and Bundler 2.x so a fresh clone installs and tests cleanly.
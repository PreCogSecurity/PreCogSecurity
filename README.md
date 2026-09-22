# PreCogSecurity

Artificial Intelligence & Social Analytics Tool — a work in progress.

This repository is a monorepo-style collection of prototypes and research
artifacts. The primary runnable application is the Rails task-tracking app in
[`todo/`](todo/), which is the component with an automated test suite and CI
coverage.

## Repository layout

| Path | What it is |
| --- | --- |
| [`todo/`](todo/) | Rails 4.2 application ("Getting Things Done" task tracker). The maintained, tested component. |
| [`precog/`](precog/) | Static marketing/demo site (HTML/CSS/JS) plus early prototypes (`blog/`, `socify/`, `social/`). |
| [`blog/`](blog/) | Older Rails prototype (blog engine), not maintained. |
| [`article/`](article/) | Archived research material (scraped web content used as source data). |
| [`opencog/`](opencog/) | Research notes / experiments. |
| [`aaa-debian-repo/`](aaa-debian-repo/) | Packaging scratch space. |

## Prerequisites

- Ruby **2.7.x** — the last Ruby line supported by Rails 4.2 (the framework
  this app runs on). Newer Rubies are not supported by Rails 4.2.
- Bundler 2.x (`gem install bundler`)
- SQLite 3 (development/test databases)

## Install

```sh
cd todo
bundle install
```

The committed `Gemfile.lock` predates Ruby 2.7 and pins gems that no longer
compile on modern toolchains; `bundle install` regenerates it from the
modernized `Gemfile` on first run.

## Run

```sh
cd todo
bundle exec rake db:create db:migrate
bundle exec rails server
```

Open <http://localhost:3000>.

Production deployments must provide configuration via environment variables —
see [`todo/.env.example`](todo/.env.example):

- `SECRET_KEY_BASE` — required in production (Rails refuses to boot without it)
- `DATABASE_URL` — required in production (fail-closed)
- `DB_POOL`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT`

## Test

```sh
cd todo
bundle exec rake db:test:prepare
bundle exec rails test
```

The suite covers models, controllers, helpers, and the health endpoint, and
emits a SimpleCov coverage report on every run. Lint with:

```sh
cd todo
bundle exec rubocop
```

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs the test suite, RuboCop, and
an informational `bundler-audit` dependency scan on every push and pull
request.

## Security notes

- Secrets are never committed: `SECRET_KEY_BASE` and `DATABASE_URL` are read
  from the environment in production (fail-closed boot).
- The app enforces CSRF protection with `with: :exception`, strong parameters,
  and typed JSON error responses for bad input.
- The vendored third-party JavaScript (jQuery, jQuery UI, Bootstrap, Isotope)
  has been removed from the tree and is referenced from pinned CDN URLs
  instead — see `todo/app/views/layouts/application.html.erb` and
  `precog/index.html`.

## Status

Work in progress. The `todo/` app is the current focus; the remaining
directories are historical prototypes and research artifacts.
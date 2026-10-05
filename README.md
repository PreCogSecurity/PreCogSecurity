# PreCogSecurity

Artificial Intelligence & Social Analytics Tool — a work in progress.

## Primary stack

**Ruby on Rails 4.2 (Ruby 2.7) is the primary stack of this repository.** It is a
Rails monorepo with one actively built application, not an infrastructure-as-code
project: there is no Terraform, Kubernetes, Helm, Pulumi or Ansible in this tree.
`todo/` is the application that is built, tested, linted, audited in CI and
containerised; every other directory is a historical artifact.

## Repository layout

| Path | What it is | In the build path? |
| --- | --- | --- |
| [`todo/`](todo/) | Rails 4.2 GTD task-tracker app. The maintained, tested, shipped component. | **Yes** |
| [`precog/`](precog/) | 2013-era static marketing site plus three dead Rails/App Engine stubs. See [`precog/ARCHIVED.md`](precog/ARCHIVED.md). | No |
| [`blog/`](blog/) | Oldest Rails blog prototype, no lockfile. See [`blog/ARCHIVED.md`](blog/ARCHIVED.md). | No |
| [`article/`](article/) | Archived research material (mirrored web pages used as source data). | No |
| [`opencog/`](opencog/) | Research notes only. See [`opencog/ARCHIVED.md`](opencog/ARCHIVED.md). | No |
| `aaa-debian-repo/` | Empty packaging scratch directory. | No |

Nothing outside `todo/` is built, tested, linted or deployed. Each archived
directory carries an `ARCHIVED.md` stating so; if you need to revive one, start
by giving it a lockfile and a passing test suite.

## Prerequisites

- Ruby **2.7.x** — the last Ruby line supported by Rails 4.2 (the framework
  this app runs on). Pinned by [`.ruby-version`](.ruby-version).
- Bundler **1.17.3** — the final 1.x release, recorded in the `BUNDLED WITH`
  section of `todo/Gemfile.lock`. Use the same major version the lockfile was
  resolved with.
- SQLite 3 (development/test databases)

## Install

From a fresh clone, one command at the repository root:

```sh
make install
```

Or, equivalently, directly:

```sh
cd todo
bundle install
```

`todo/Gemfile.lock` is committed and reproducible: it pins Rails 4.2.11.3 (the
final 4.2.x release, which carries every backported security fix) together with
its resolved dependency set. There is deliberately **no vendored `vendor/cache`
in the tree** — a stale gem cache can win during resolution and silently
reintroduce unpatched versions, so dependency resolution comes from the lockfile
alone.

## Run

```sh
make run
```

or:

```sh
cd todo
bundle exec rake db:create db:migrate
bundle exec rails server
```

Open <http://localhost:3000>.

## Test

```sh
make test
```

or:

```sh
cd todo
bundle exec rake db:test:prepare
bundle exec rails test
```

`make check` runs everything CI runs — prepare, lint, test, audit — in one go.

### Coverage

Every test run emits a SimpleCov report to `todo/coverage/index.html` and
**fails the run if line coverage falls below a floor** (default 60%, see
`todo/test/test_helper.rb`). The floor is a ratchet: measure the suite locally
and raise it once you have the number.

```sh
cd todo
COVERAGE_MINIMUM=80 bundle exec rails test   # try a higher bar without editing code
```

The suite covers models, controllers, helpers, the JSON feed, the security
headers and the end-to-end task lifecycle (`test/integration/`).

## Lint

```sh
make lint
```

or `cd todo && bundle exec rubocop`. Configuration lives in
[`todo/.rubocop.yml`](todo/.rubocop.yml); it enables the Lint and Security cop
families rather than imposing a style migration on Rails-4-era code.

## CI

GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs on
every push and pull request:

| Job | What it gates |
| --- | --- |
| `test` | `db:test:prepare`, the suite, the coverage floor, RuboCop. |
| `container` | Builds the `todo/` image, asserts no secret is baked into it, and asserts the app **refuses to boot** in production without `SECRET_KEY_BASE`. |
| `audit` | `bundler-audit` against the advisory database (informational — Rails 4.2 is EOL, so findings stay visible without blocking unrelated work). |

[`dependabot.yml`](.github/dependabot.yml) proposes weekly bundler and
GitHub Actions updates.

## Configuration and secrets

Secrets are never committed. Production configuration is read from the
environment — see [`todo/.env.example`](todo/.env.example):

- `SECRET_KEY_BASE` — required in production
- `DATABASE_URL` — required in production
- `DB_POOL`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT` — optional

`todo/config/environments/production.rb` **raises at boot** if either required
variable is missing or blank, on every database adapter, so a misconfigured
deploy fails loudly at start-up instead of silently signing cookies with a
guessable key or failing on the first request.

### Local containers

```sh
make docker-up
```

`todo/docker-compose.yml` brings up Postgres plus the Rails image. It refuses to
start without `SECRET_KEY_BASE` set in your shell.

## Security notes

- **Fail-closed boot.** `SECRET_KEY_BASE` and `DATABASE_URL` are read from the
  environment; production refuses to start without them.
- **CSRF.** `protect_from_forgery with: :exception`, so a missing token raises
  instead of silently nulling the session.
- **Strong parameters and list scoping.** Task writes are scoped to the parent
  list from the nested route, and `list_id` is *not* permitted on update — a task
  cannot be re-parented into another list.
- **Input validation.** Malformed JSON and non-object task parameters return
  `400`, not `500`. `list_id` is accepted only as a plain integer before it can
  reach the database adapter. Model-level length caps bound what can be stored.
- **Output encoding.** Task names are escaped, auto-linked, then run through a
  strict tag/attribute allowlist (`TasksHelper#linked_task_name`). The index view
  no longer calls `raw`, so there is no unescaped-markup path in the app.
- **Response headers.** A middleware attaches `Content-Security-Policy`,
  `X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff`,
  `Referrer-Policy: strict-origin-when-cross-origin` and
  `X-Permitted-Cross-Domain-Policies: none` to every response, including static
  files and error responses.
- **Transport and cookies.** `config.force_ssl` in production; the session
  cookie is `HttpOnly` and `Secure`.
- **Log hygiene.** Request parameters matching `passw`, `secret`, `token`,
  `api_key`, `session`, `cookie`, `authorization` and friends are redacted
  before logging.
- **Bounded API.** The JSON task feed is list-scoped and capped at 200 records
  instead of serialising the whole table.
- **Purged from history-of-the-tree.** A scraped Netscape cookie jar containing
  live third-party session cookies, the matching HTTrack download cache, and a
  16 MB vendored `vendor/cache` of pre-patch gems are no longer in the
  repository; `.gitignore` now blocks their return.

## Status

Work in progress. The `todo/` app is the current focus; every other directory is
a historical prototype or research artifact. See [`CHANGELOG.md`](CHANGELOG.md).
# Todo for everyone

Simple GTD (Getting Things Done) app for task tracking, built on Rails 4.2.

This is the only actively built, tested and shipped component of the repository.
From the repository root, `make install`, `make test`, `make lint` and
`make run` all drive this directory — see the [top-level README](../README.md).

## Prerequisites

- Ruby 2.7.x (see `../.ruby-version`)
- Bundler 1.17.3, matching the `BUNDLED WITH` entry in `Gemfile.lock`
- SQLite 3 for development and test

## Setup

```sh
bundle install
bundle exec rake db:create db:migrate
bundle exec rails server
```

`Gemfile.lock` is committed and reproducible. Do not add a vendored
`vendor/cache` of `.gem` files: a stale cache can win during resolution and
silently resolve to unpatched versions.

## Tests

Run the full suite:

```sh
bundle exec rake db:test:prepare
bundle exec rails test
```

Run a single test file (for example):

```sh
bundle exec ruby -Itest test/controllers/lists_controller_test.rb
```

Run a specific test by name (for example):

```sh
bundle exec ruby -Itest test/controllers/lists_controller_test.rb --name test_should_create_list
```

A SimpleCov coverage report is written to `coverage/` after every test run, and
the run **fails** if line coverage drops below the floor (default 60%). Try a
higher bar without editing code:

```sh
COVERAGE_MINIMUM=80 bundle exec rails test
```

Raise the default in `test/test_helper.rb` once you have measured the suite.

## Lint

```sh
bundle exec rubocop
```

See `.rubocop.yml`. Only the Lint and Security cop families are enabled, so the
Rails-4-era hash-rocket style is not churned.

## Configuration

All production configuration is read from environment variables — see
[`.env.example`](.env.example). `SECRET_KEY_BASE` and `DATABASE_URL` are
required in production; `config/environments/production.rb` raises at boot
without them rather than falling back to a default.

## Local containers

```sh
docker compose build        # requires SECRET_KEY_BASE in your environment
docker compose up
```

See `docker-compose.yml` and `Dockerfile`.
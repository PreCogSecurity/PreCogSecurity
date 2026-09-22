# Todo for everyone

Simple GTD (Getting Things Done) app for task tracking, built with Rails 4.2.

Supports all Rubies and many stacks (passenger, unicorn, trinidad/jruby).

## Setup

```sh
bundle install
bundle exec rake db:create db:migrate
bundle exec rails server
```

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

A SimpleCov coverage report is written to `coverage/` after every test run.

## Lint

```sh
bundle exec rubocop
```

## Configuration

All production configuration is read from environment variables — see
[`.env.example`](.env.example). `SECRET_KEY_BASE` and `DATABASE_URL` are
required in production; the app fails to boot without them.
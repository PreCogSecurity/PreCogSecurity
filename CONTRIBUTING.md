# Contributing

Thanks for considering a contribution to PreCogSecurity.

## Getting started

1. Clone the repository. Ruby 2.7.x is required; the version is pinned in
   `.ruby-version`.
2. Install dependencies and prepare the database:

   ```sh
   make install
   make prepare
   ```

   `make` targets simply delegate into `todo/`, the maintained Rails app. You
   can also `cd todo` and run the underlying commands directly.
3. Run the test suite before and after your change:

   ```sh
   make test        # test + coverage floor
   make lint        # rubocop
   make check       # prepare + lint + test + audit, i.e. everything CI runs
   ```

## Guidelines

- **Ship features with their tests.** Every behavior change lands with tests
  that pin the new behavior — one focused commit (or small PR) per change.
- **Do not mix concerns.** Keep formatting, refactors, and features in
  separate commits so history stays reviewable.
- **Never commit secrets.** Configuration values (database URLs, secret keys,
  API tokens) belong in environment variables, documented in
  `todo/.env.example`. The same applies to tooling side effects: never commit a
  browser or scraper cookie jar, download cache, or `.env` file.
- **Do not vendor gems or third-party code.** There is no `vendor/cache` and no
  in-tree copy of third-party JavaScript; dependencies come from
  `todo/Gemfile.lock` or from pinned CDN URLs. See `precog/ARCHIVED.md` for why
  an in-tree copy of a library is a liability rather than a convenience.
- **Keep the CI green.** The GitHub Actions workflow runs tests with a coverage
  floor, RuboCop, a container build, and a dependency audit on every push; do
  not merge changes that fail it.
- **Raise the coverage floor, don't lower it.** If your change adds
  well-covered code, consider bumping `COVERAGE_MINIMUM` in the same commit.

## Reporting security issues

Do not open a public issue for security vulnerabilities. Report them privately
to the maintainers so a fix can be shipped before details are disclosed.
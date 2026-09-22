# Contributing

Thanks for considering a contribution to PreCogSecurity.

## Getting started

1. Clone the repository.
2. Follow the setup instructions in the [README](README.md) — the `todo/`
   Rails app is the maintained component.
3. Run the test suite before and after your change:

   ```sh
   cd todo
   bundle exec rake db:test:prepare
   bundle exec rails test
   ```

4. Run the linter:

   ```sh
   cd todo
   bundle exec rubocop
   ```

## Guidelines

- **Ship features with their tests.** Every behavior change lands with tests
  that pin the new behavior — one focused commit (or small PR) per change.
- **Do not mix concerns.** Keep formatting, refactors, and features in
  separate commits so history stays reviewable.
- **Never commit secrets.** Configuration values (database URLs, secret keys,
  API tokens) belong in environment variables, documented in
  `todo/.env.example`.
- **Do not vendor third-party code.** Front-end libraries are referenced from
  pinned CDN URLs; if a library must be vendored, add it to `.gitignore` and
  document the offline-build exception.
- **Keep the CI green.** The GitHub Actions workflow runs tests, RuboCop, and
  a dependency audit on every push; do not merge changes that fail it.

## Reporting security issues

Do not open a public issue for security vulnerabilities. Report them privately
to the maintainers so a fix can be shipped before details are disclosed.
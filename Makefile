# Top-level developer entry points for the PreCogSecurity monorepo.
#
# The only actively built, tested, linted and deployable component is the Rails
# app in todo/. Every target below delegates into that directory so that a fresh
# clone has one obvious, discoverable way to install, test and lint the project
# from the repository root -- `make help` lists them.
#
# Nothing outside todo/ is in the build path. See README.md ("Repository
# layout") for why the other directories are quarantined.

APP_DIR := todo

# Bundler version pinned by .ruby-version / todo/Dockerfile / CI. Rails 4.2's
# gemspec requires bundler < 2.0 and 1.17.3 is the final 1.x release.
BUNDLER_VERSION ?= 1.17.3

# Coverage floor enforced by todo/test/test_helper.rb. Override locally with
# `make test COVERAGE_MINIMUM=90` once the suite has been measured; see
# README.md ("Coverage") for the ratchet policy.
COVERAGE_MINIMUM ?= 60

.DEFAULT_GOAL := help
.PHONY: help install prepare test lint audit check run clean docker-build docker-up docker-down

help: ## Show this help
	@echo "PreCogSecurity -- available targets:"
	@echo "  make install    Install gems for $(APP_DIR)/ (bundle install)"
	@echo "  make prepare    Create and migrate the development database"
	@echo "  make test       Run the full test suite with a coverage floor"
	@echo "  make lint       Run RuboCop (Lint + Security cop families)"
	@echo "  make audit      Run bundler-audit (known CVE check)"
	@echo "  make check      prepare + lint + test + audit (pre-push gate)"
	@echo "  make run        Boot the Rails server on :3000"
	@echo "  make clean      Remove generated coverage/tmp artefacts"
	@echo "  make docker-up  Build and start the $(APP_DIR)/ stack via compose"

install: ## Install gem dependencies for the Rails app
	cd $(APP_DIR) && gem install bundler -v '$(BUNDLER_VERSION)' --no-document || true
	cd $(APP_DIR) && bundle install

prepare: ## Create and migrate the development database
	cd $(APP_DIR) && bundle exec rake db:create db:migrate

test: ## Run the test suite (fails under the coverage floor)
	cd $(APP_DIR) && COVERAGE_MINIMUM=$(COVERAGE_MINIMUM) bundle exec rake db:test:prepare
	cd $(APP_DIR) && COVERAGE_MINIMUM=$(COVERAGE_MINIMUM) bundle exec rails test

lint: ## Run the linter
	cd $(APP_DIR) && bundle exec rubocop

audit: ## Audit locked gems against the bundler-audit CVE database
	cd $(APP_DIR) && gem install bundler-audit --no-document
	cd $(APP_DIR) && bundle exec bundle-audit check --update

check: prepare lint test audit ## Everything CI runs, in one command

run: ## Boot the development server
	cd $(APP_DIR) && bundle exec rails server

clean: ## Remove generated artefacts
	rm -rf $(APP_DIR)/coverage $(APP_DIR)/tmp

docker-build: ## Build the container image for todo/
	docker compose -f $(APP_DIR)/docker-compose.yml build

docker-up: ## Start the todo/ stack (Postgres + Rails) via compose
	docker compose -f $(APP_DIR)/docker-compose.yml up --build

docker-down: ## Stop the todo/ stack and remove its volumes
	docker compose -f $(APP_DIR)/docker-compose.yml down -v
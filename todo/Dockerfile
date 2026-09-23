# Rails 4.2 requires Ruby 2.7 — the last Ruby line the framework supports.
# The slim image keeps the runtime small; build tools are installed only so
# native gems (sqlite3, mysql2, pg, nokogiri) can compile.
FROM ruby:2.7-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
      libmysqlclient-dev \
      libpq-dev \
      curl \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

WORKDIR /app

# Install gems before copying the app so dependency layers cache well.
# Rails 4.2's gemspec requires bundler < 2.0; 1.17.3 is the final 1.x release.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v '1.17.3' \
    && bundle config set --local path vendor/bundle \
    && bundle config set --local without development test \
    && bundle install

COPY . .

EXPOSE 3000

# Migrate (idempotent) then serve. SECRET_KEY_BASE and DATABASE_URL must be
# provided via the environment; the app fails closed at boot without them.
CMD ["sh", "-c", "bundle exec rake db:migrate && bundle exec puma -p 3000"]
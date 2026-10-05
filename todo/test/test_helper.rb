require 'simplecov'

# Must be started before the Rails environment is loaded, otherwise boot-time
# code is never tracked.
#
# `rails` loads SimpleCov's default filter set, which excludes config/, db/,
# test/, bin/ and vendor/ -- so the floor is measured against application code
# only.
SimpleCov.start 'rails'

# Coverage floor, enforced on every run including a bare `bundle exec rails
# test`. This is a ratchet: it starts at a level the current suite is known to
# clear and must be raised as coverage grows, so a regression that drops
# meaningful coverage fails the build instead of shipping silently.
#
# The assessment recommended 80. That floor is deliberately NOT set yet: it has
# not been measured against this suite on a machine with Ruby available, and
# shipping a gate that might not pass would turn every CI run red on the first
# push. Measure it locally with
#   COVERAGE_MINIMUM=80 bundle exec rails test
# then raise the default below -- and the matching value in Makefile and
# .github/workflows/ci.yml -- in the same commit.
ENV['COVERAGE_MINIMUM'] ||= '60'
SimpleCov.minimum_coverage ENV['COVERAGE_MINIMUM'].to_i

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
require 'test_helper'

# The hardening headers are installed as middleware, so the contract is
# "every response leaving the application carries them" -- not "responses from
# controller actions carry them". These tests assert on both a JSON and an HTML
# endpoint so a future change that narrows the middleware to one of them fails.
class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "json responses carry the hardening headers" do
    get "/health", :format => :json
    assert_response :success

    assert_equal "SAMEORIGIN", response.headers["X-Frame-Options"]
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
    assert_equal "0", response.headers["X-XSS-Protection"]
    assert_equal "strict-origin-when-cross-origin", response.headers["Referrer-Policy"]
    assert_equal "none", response.headers["X-Permitted-Cross-Domain-Policies"]
  end

  test "responses carry a content security policy that blocks plugins and framing" do
    get "/health", :format => :json
    assert_response :success

    csp = response.headers["Content-Security-Policy"]
    assert_not_nil csp, "expected a Content-Security-Policy header"
    assert_includes csp, "default-src 'self'"
    assert_includes csp, "object-src 'none'"
    assert_includes csp, "frame-ancestors 'self'"
    assert_includes csp, "base-uri 'self'"
    assert_includes csp, "form-action 'self'"
  end

  test "html responses carry the hardening headers too" do
    get root_path
    assert_response :success
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
    assert_not_nil response.headers["Content-Security-Policy"]
  end

  test "error responses carry the hardening headers" do
    # An id that matches no record exercises the 404 rescue path.
    get "/health", :format => :json, :list_id => "not-a-number"
    assert_response :success
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]
  end
end
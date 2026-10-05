# Rack middleware that attaches hardening headers to *every* response.
#
# This is deliberately a middleware rather than an after_action in
# ApplicationController: as middleware it also covers responses produced
# outside the controller layer -- static files served by
# ActionDispatch::Static, unhandled exceptions, and any future Rack app mounted
# in this process. An after_action would silently skip all of those.
#
# Strict-Transport-Security is NOT set here on purpose: config.force_ssl pulls
# in Rack::SSL, which already emits `Strict-Transport-Security: max-age=31536000`.
# Emitting a second, possibly conflicting HSTS header from two layers is how you
# get an inconsistent max-age, so this middleware stays out of it.
module PreCogSecurity
  class SecurityHeaders
    # `script-src` has to permit 'unsafe-inline' because Rails 4.2 cannot mint
    # per-request nonces (nonce support arrived in Rails 5.2) and the tabs
    # bootstrap is an inline <script> block. Everything else is locked down, so
    # this still blocks injected remote scripts, plugins, framing and base-tag
    # hijacking. When the inline scripts move into the asset pipeline, drop
    # 'unsafe-inline' from script-src.
    CONTENT_SECURITY_POLICY = [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' https://ajax.googleapis.com",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data:",
      "font-src 'self' data:",
      "connect-src 'self'",
      "form-action 'self'",
      "frame-ancestors 'self'",
      "base-uri 'self'",
      "object-src 'none'"
    ].join('; ').freeze

    # X-XSS-Protection is set to 0, not 1; mode=block. OWASP now recommends
    # disabling the legacy auditor outright because on modern browsers it can
    # itself introduce XSS via crafted pages. The real protection here is the
    # Content-Security-Policy above plus output escaping in TasksHelper.
    HEADERS = {
      'Content-Security-Policy'           => CONTENT_SECURITY_POLICY,
      'X-Frame-Options'                   => 'SAMEORIGIN',
      'X-Content-Type-Options'            => 'nosniff',
      'X-XSS-Protection'                  => '0',
      'Referrer-Policy'                   => 'strict-origin-when-cross-origin',
      'X-Permitted-Cross-Domain-Policies' => 'none'
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      [status, apply(headers), body]
    end

    private

    def apply(headers)
      # Some middleware in the stack return a frozen header hash; copy rather
      # than blow up on the first header we try to set.
      headers = headers.dup if headers.frozen?
      HEADERS.each { |name, value| headers[name] = value }
      headers
    end
  end
end
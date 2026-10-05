# Be sure to restart your server when you modify this file.

# Cookies are signed with SECRET_KEY_BASE, so the flags are stated explicitly
# rather than inherited from defaults:
#
#   httponly - keeps the session cookie out of reach of client-side script, so
#              an XSS in this app cannot exfiltrate the session
#   secure   - production only, and consistent with config.force_ssl, which
#              already redirects plain HTTP. Sending the cookie over a
#              TLS-terminating proxy works because the app only ever receives
#              the request after force_ssl has verified it.
Rails.application.config.session_store :cookie_store,
  :key     => '_listr_session',
  :httponly => true,
  :secure  => Rails.env.production?
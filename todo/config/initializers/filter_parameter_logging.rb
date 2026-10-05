# Be sure to restart your server when you modify this file.

# Redact sensitive request parameters before they reach the logs.
#
# The app has no login form today, but :password alone is not enough: as soon as
# any credential, token or cookie-derived value is accepted on a request it
# would be written verbatim to the log file, which is exactly where a log
# scraper, a support bundle or a shipped log archive would pick it up. Listing
# the names up front means the redaction is already correct on the day the field
# is added, instead of the day someone remembers to audit it.
Rails.application.config.filter_parameters += [
  :passw,          # matches password, password_confirmation, password_digest
  :secret,
  :token,
  :api_key,
  :access_token,
  :refresh_token,
  :session,
  :cookie,
  :authorization,
  :otp,
  :otp_secret,
  :signature
]
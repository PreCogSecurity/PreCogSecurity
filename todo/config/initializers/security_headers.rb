# Installs PreCogSecurity::SecurityHeaders as the outermost middleware so that
# every response leaving the application carries the hardening headers.
#
# Required explicitly rather than autoloaded: constant autoloading is not
# available while initializers are running, and a middleware reference that
# fails to resolve here fails the whole boot.
require Rails.root.join('lib', 'security_headers').to_s

# insert_before 0 puts this ahead of ActionDispatch::Static and the router, so
# the headers land on static-file and error responses too, not only on
# responses that happen to come out of a controller action.
Rails.application.config.middleware.insert_before 0, PreCogSecurity::SecurityHeaders
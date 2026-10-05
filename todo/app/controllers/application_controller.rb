class ApplicationController < ActionController::Base
  # `with: :exception` raises on a missing/invalid CSRF token instead of the
  # Rails 4 default of silently nulling the session, which is a session-fixation
  # vector. JSON API clients must send the CSRF token (see csrf_meta_tags in
  # the layout) or use a token-authenticated API layer.
  protect_from_forgery with: :exception

  # Identifiers in this app are always auto-incrementing integer primary keys,
  # so anything that is not a plain run of digits can be rejected up front.
  NUMERIC_ID_FORMAT = /\A\d{1,10}\z/.freeze

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request

  protected

  # Validate a URL-supplied identifier and return it as an Integer.
  #
  # Every find-by-id in this app goes through here rather than passing the raw
  # parameter to Active Record. Active Record quotes the value so this is not a
  # SQL injection vector, but a non-integer value for an integer column is a
  # driver-level error: PostgreSQL raises PG::InvalidTextRepresentation and
  # MySQL raises Mysql2::Error, so a junk id produced an unhandled 500 (with an
  # adapter-specific message) instead of a client error. Validating the shape
  # gives one consistent 400 for every adapter.
  def numeric_id!(name)
    value = params[name].to_s
    unless value =~ NUMERIC_ID_FORMAT
      raise ActionController::BadRequest, "#{name} must be a positive integer"
    end

    value.to_i
  end

  private

  def render_not_found(exception)
    logger.warn "record_not_found: #{exception.message}"
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'The requested record could not be found.' }
      format.json { render json: { error: 'not_found', message: exception.message }, status: :not_found }
    end
  end

  def render_unprocessable_entity(exception)
    logger.warn "record_invalid: #{exception.message}"
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'The record could not be saved.' }
      format.json { render json: { error: 'unprocessable_entity', message: exception.message }, status: :unprocessable_entity }
    end
  end

  def render_bad_request(exception)
    logger.warn "bad_request: #{exception.message}"
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'The request was malformed.' }
      format.json { render json: { error: 'bad_request', message: exception.message }, status: :bad_request }
    end
  end
end
class ApplicationController < ActionController::Base
  # `with: :exception` raises on a missing/invalid CSRF token instead of the
  # Rails 4 default of silently nulling the session, which is a session-fixation
  # vector. JSON API clients must send the CSRF token (see csrf_meta_tags in
  # the layout) or use a token-authenticated API layer.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :render_bad_request
  rescue_from ActionController::BadRequest, with: :render_bad_request

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
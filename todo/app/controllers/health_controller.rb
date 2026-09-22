class HealthController < ApplicationController
  # Lightweight liveness/readiness probe for load balancers and uptime
  # monitors. Returns 200 with a JSON body when the app and its database
  # connection are healthy, 503 otherwise.
  def show
    database_ok = database_connected?
    render :json => {
      :status   => database_ok ? 'ok' : 'degraded',
      :time     => Time.now.utc.iso8601,
      :database => database_ok
    }, :status => (database_ok ? :ok : :service_unavailable)
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue StandardError => e
    # Rescue broadly: the adapter-specific exception classes (PG::Error,
    # Mysql2::Error, SQLite3::Exception) are not all loaded in every
    # environment, and the health endpoint must never 500.
    logger.warn "health_check: database connection failed: #{e.class}: #{e.message}"
    false
  end
end
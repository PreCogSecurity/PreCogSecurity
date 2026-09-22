# Structured JSON logging for production.
#
# Emits one JSON object per log line so logs can be shipped to log
# aggregation / SIEM tooling without a parsing layer. This is a
# dependency-free alternative to a full semantic-logging gem.
class JsonLogFormatter < ::Logger::Formatter
  def call(severity, time, progname, msg)
    {
      'timestamp' => time.utc.iso8601(3),
      'level'     => severity,
      'progname'  => progname,
      'message'   => msg2str(msg)
    }.to_json << "\n"
  end
end
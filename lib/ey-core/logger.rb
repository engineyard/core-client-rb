class Ey::Core::Logger < Faraday::Response::Middleware
  extend Forwardable

  def initialize(app, logger = nil)
    super(app)
    @logger = logger || ::Logger.new(nil)
  end

  def_delegators :@logger, :debug, :info, :warn, :error, :fatal

  def call(env)
    debug "REQUEST: #{env[:method].upcase} #{env[:url].to_s}"
    debug('request') { dump_headers env[:request_headers] }
    debug('request.body') { env[:body] }
    debug('')
    super
  end

  def on_complete(env)
    debug "RESPONSE: #{env[:status]}"
    debug('response') { dump_headers env[:response_headers] }
    debug('response.body') { env[:body] }
    debug('')
  end

  private

  def dump_headers(headers)
    headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
  end
end

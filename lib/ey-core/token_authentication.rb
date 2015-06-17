class Ey::Core::TokenAuthentication < Faraday::Response::Middleware
  attr_reader :token

  def initialize(app, token)
    super(app)
    @token = token
  end

  def call(env)
    env[:request_headers]["X-EY-TOKEN"] = token
    super
  end
end

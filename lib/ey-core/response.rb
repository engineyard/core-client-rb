class Ey::Core::Response
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super(
        {
          :status  => response.status,
          :headers => response.headers,
          :body    => response.body,
          :request => response.request
        }.inspect
      )
    end
  end

  BadRequest        = Class.new(Error)
  Conflict          = Class.new(Error)
  NotFound          = Class.new(Error)
  RateLimitExceeded = Class.new(Error)
  Unauthorized      = Class.new(Error)
  Unexpected        = Class.new(Error)
  Unprocessable     = Class.new(Error)

  EXCEPTION_MAPPING = {
    400 => BadRequest,
    401 => Unauthorized,
    404 => NotFound,
    409 => Conflict,
    422 => Unprocessable,
    429 => RateLimitExceeded,
    500 => Unexpected,
  }

  attr_reader :headers, :status, :body, :request

  def initialize(opts = {})
    @status  = opts[:status]
    @headers = opts[:headers]
    @body    = opts[:body]
    @request = opts[:request]
  end

  def successful?
    self.status >= 200 && self.status <= 299 || self.status == 304
  end

  def raise!
    if !successful?
      raise (EXCEPTION_MAPPING[self.status] || Error).new(self)
    else self
    end
  end
end

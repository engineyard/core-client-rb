class Ey::Core::Client::Real
  include Ey::Core::Client::Shared

  def initialize(options={})
    setup(options)
    adapter            = options[:adapter] || Faraday.default_adapter
    connection_options = options[:connection_options] || {}

    @connection = Faraday.new({url: @url}.merge(connection_options)) do |builder|
      # response
      builder.response :json, content_type: /json/

      builder.use Ey::Core::ResponseCache, cache: @cache if @cache

      # request
      builder.request :multipart
      builder.request :json

      # request
      builder.request :retry,
        :max                 => 5,
        :interval            => 1,
        :interval_randomness => 0.05,
        :backoff_factor      => 2

      unless @authentication == :none
        if @token
          builder.use Ey::Core::TokenAuthentication, @token
        else
          builder.use :hmac, @auth_id, @auth_key
        end
      end

      builder.use Ey::Core::Logger, @logger

      if options[:builder]
        options[:builder].call(builder)
      end

      builder.adapter(*adapter)
    end
  end

  def request(options={})
    method  = options[:method] || :get
    url     = options[:url] || File.join(@url, options[:path] || "/")
    #@todo query is a band-aid
    query   = options[:query] || {}
    params  = query.merge(options[:params] || {})
    body    = options[:body]
    headers = options[:headers] || {}

    default_content_type = if !body && !params.empty?
                             "application/x-www-form-urlencoded"
                           else
                             "application/json"
                           end
    headers = {
      "Content-Type" => default_content_type,
      "Accept"       => accept_type,
    }.merge(headers)

    response = @connection.send(method) do |req|
      req.url(url)
      req.headers.merge!(headers)
      req.params.merge!(params)
      req.body = body
    end

    Ey::Core::Response.new(
      :status  => response.status,
      :headers => response.headers,
      :body    => response.body,
      :request => {
        :method  => method,
        :url     => url,
        :headers => headers,
        :body    => body,
        :params  => params,
      }
    ).raise!
  end

  def accept_type
    "application/vnd.engineyard.v2+json"
  end

  def reset!
    request(method: :post, path: "/client/reset")
  rescue Ey::Core::Response::NotFound # allow me to test against something real where this route doesn't exist
    nil
  end
end

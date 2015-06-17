class Ey::Core::ResponseCache
  def initialize(app, options = {}, &block)
    @app = app
    @cache = options.fetch(:cache, &block)
    @cache_key_prefix = options.fetch(:cache_key_prefix, :ey_core)
  end

  def call(env)
    # Only cache "safe" requests
    return @app.call(env) unless [:get, :head].include?(env[:method])

    cache_key = [ @cache_key_prefix, env[:url].to_s ]
    cached = @cache.read(cache_key)

    if cached
      env[:request_headers]["If-None-Match"] ||= cached[:response_headers]["Etag"]
    end

    @app.call(env).on_complete do
      if cached && env[:status] == 304
        env[:body] = cached[:body]
      end

      if !cached && env[:response_headers]["Etag"]
        @cache.write(cache_key, env)
      end
    end
  end
end

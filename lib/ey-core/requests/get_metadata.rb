class Ey::Core::Client
  class Real
    def get_metadata(params={})
      url = params["url"]

      request(
        :path => "metadata",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_metadata(params={})
      response(
        :body   => {
          environment: "mock",
          revision: "mock",
          version: "mock",
          now: Time.now
        },
        :status => 200,
        )
    end
  end # Mock
end # Ey::Core::Client

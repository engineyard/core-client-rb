class Ey::Core::Client
  class Real
    def get_metadata(params={})
      request(path: "metadata")
    end
  end # Real

  class Mock
    def get_metadata(params={})
      response(
        :body => {
          "core" => {
            "environment" => "mock",
            "revision"    => "mock",
            "version"     => "mock",
            "now"         => Time.now,
          }
        },
      )
    end
  end # Mock
end # Ey::Core::Client

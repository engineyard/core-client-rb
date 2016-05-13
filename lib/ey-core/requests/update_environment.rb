class Ey::Core::Client
  class Real
    def update_environment(params={})
      request(
        :method => :put,
        :path   => "/environments/#{params.fetch("id")}",
        :body   => {"environment" => params.fetch("environment")},
      )
    end
  end

  class Mock
    def update_environment(params={})
      raise NotImplementedError
    end
  end
end

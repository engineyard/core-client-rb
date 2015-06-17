class Ey::Core::Client
  class Real
    def get_log(params={})
      id = params["id"]
      url = params["url"]

      request(
        :path => "logs/#{id}",
        :url => url
      )
    end
  end

  class Mock
    def get_log(params={})
      response(
        :body => {"log" => self.find(:logs, resource_identity(params))},
      )
    end
  end
end

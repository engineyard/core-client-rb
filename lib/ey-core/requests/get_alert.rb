class Ey::Core::Client
  class Real
    def get_alert(params={})
      id = params["id"]
      url = params["url"]

      request(
        :path => "/alerts/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_alert(params={})
      response(
        :body => { "alert" => self.find(:alerts, resource_identity(params)) }
      )
    end
  end # Mock
end

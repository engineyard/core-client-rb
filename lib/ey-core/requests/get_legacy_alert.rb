class Ey::Core::Client
  class Real
    def get_legacy_alert(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/legacy-alerts/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_legacy_alert(params={})
      response(
        :body   => {"legacy_alert" => self.find(:legacy_alerts, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

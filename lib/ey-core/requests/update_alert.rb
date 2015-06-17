class Ey::Core::Client
  class Real
    def update_alert(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      id = params.delete("id")
      body = { alert: params["alert"] }

      request(
        :method => :put,
        :path   => "/alerts/#{id}",
        :body   => body,
      )
    end
  end

  class Mock
    def update_alert(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      identity = params["id"]
      alert  = find(:alerts, identity)

      update_params = Cistern::Hash.slice(params["alert"],
                                          "acknowledged", "ignored", "severity", "finished_at", "external_id", "started_at", "message")

      alert.merge!(update_params.merge!("updated_at" => Time.now))

      response(
        :body => { "alert" => alert },
      )
    end
  end
end

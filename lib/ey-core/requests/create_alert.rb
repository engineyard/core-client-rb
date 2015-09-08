class Ey::Core::Client
  class Real
    def create_alert(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/alerts",
        :body   => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_alert(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      extract_url_params!(params)

      database_server_id = resource_identity(params["database_server"] || params["database_server_id"])
      server_id          = resource_identity(params["server"]          || params["server_id"])
      agent_id           = resource_identity(params["agent"]           || params["agent_id"])

      alert_params = require_parameters(params, "alert")
      name, external_id, message, severity = require_parameters(alert_params, *%w[name external_id message severity])
      resource_id = self.uuid

      alert = {
        "id"           => resource_id,
        "created_at"   => Time.now,
        "updated_at"   => Time.now,
        "deleted_at"   => nil,
        "severity"     => severity,
        "acknowledged" => alert_params.fetch("acknowledged", false),
        "ignored"      => alert_params.fetch("ignored", false),
        "message"      => message,
        "description"  => alert_params["description"],
        "external_id"  => external_id,
        "name"         => name,
        "finished_at"  => alert_params["finished_at"],
        "started_at"   => alert_params["started_at"],
      }

      alert.merge!("resource" =>
                   if database_server_id
                     url_for("/database-servers/#{database_server_id}")
                   elsif server_id
                     url_for("/servers/#{server_id}")
                   elsif agent_id
                     url_for("/agents/#{agent_id}")
                   else
                     raise response(status: 422, body: "Requires a resource")
                   end
                  )

      self.data[:alerts][resource_id] = alert
      response(
        :body   => {"alert" => alert},
        :status => 201,
      )
    end
  end # Mock
end

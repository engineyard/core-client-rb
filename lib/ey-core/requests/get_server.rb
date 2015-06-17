class Ey::Core::Client
  class Real
    def get_server(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "servers/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_server(params={})
      url = params.delete("url")
      id  = params["id"] && Integer(params["id"])

      identity = if slot_id = url && path_params(url)["slots"]
                   find(:slots, slot_id)

                   server = self.data[:servers].values.find {|s| s["slot"] == url_for("/slots/#{slot_id}") }
                   server && server["id"]
                 else
                   id || path_params(url)["servers"].to_i
                 end

      response(
        :body   => {"server" => self.find(:servers, identity)},
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client

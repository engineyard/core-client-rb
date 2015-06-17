class Ey::Core::Client
  class Real
    def destroy_database_server(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/database_servers/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_database_server(params={})
      extract_url_params!(params)
      request_id = self.uuid

      database_server_id = params["id"] || params["database_server"]

      database_server = self.find(:database_servers, database_server_id)

      request = {
        "resource"    => [:database_servers, database_server_id, database_server.merge("deleted_at" => Time.now)],
        "type"        => "deprovision_database_server",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => "true",
        "id"          => request_id,
      }

      self.data[:requests][request_id] = request

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end

class Ey::Core::Client
  class Real
    def destroy_database_server_snapshot(params={})
      (url = params["url"]) || (id = params.fetch("id"))

      request(
        :method => :delete,
        :url    => url,
        :path   => "/database-server-snapshots/#{id}",
      )
    end
  end # Real

  class Mock
    def destroy_database_server_snapshot(params={})
      request_id = self.uuid
      url        = params.delete("url")

      database_server_snapshot_id = resource_identity(url) || params.fetch("id")

      database_server_snapshot = self.data[:database_server_snapshots][database_server_snapshot_id].dup
      database_server_snapshot["deleted_at"] = Time.now
      database_server_snapshot["resource_url"] = url_for("/database_server_snapshots/#{database_server_snapshot_id}")

      # @todo use a procedure to deprovision clusters as well

      self.data[:requests][request_id] = {
        "id"          => request_id,
        "finished_at" => nil,
        "successful"  => "true",
        "started_at"  => Time.now,
        "resource"    => [:database_server_snapshots, database_server_snapshot_id, database_server_snapshot],
        "type"        => "deprovision_database_server_snapshot",
      }

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

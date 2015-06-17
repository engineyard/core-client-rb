class Ey::Core::Client
  class Real
    def discover_database_server(params={})
      id = params.delete("id")

      request(
        :method => :post,
        :path   => "/database-servers/#{id}/discover",
      )
    end
  end

  class Mock
    def discover_database_server(params={})
      request_id  = self.uuid
      resource_id = self.uuid
      id          = params["id"]

      database_server = self.data[:database_servers][id]
      old_flavor      = database_server["flavor"]
      new_flavor      = %w(db.m3.medium db.m3.large db.m3.xlarge db.m3.2xlarge) - [old_flavor]
      revisions       = self.data[:database_server_revisions][id]

      unless revisions
        database_server["flavor"]        = new_flavor
        self.data[:database_servers][id] = database_server

        revision = {
          "id"              => resource_id,
          "database_server" => url_for("/database-servers/#{id}"),
          "revision_time"   => Time.now,
          "data"            => {
            "flavor" => {
              "old" => old_flavor,
              "new" => new_flavor,
            },
          },
        }

        self.data[:database_server_revisions][id] = revision
      end

      request = {
        "id"          => request_id,
        "type"        => "discover_database_server",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:database_servers, id, database_server],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body => {"request" => response_hash},
        :status => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end
end

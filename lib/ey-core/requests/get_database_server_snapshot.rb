class Ey::Core::Client
  class Real
    def get_database_server_snapshot(params={})
      identity, url = require_argument(params, "id", "url")

      request(
        :path => identity && "/database-server-snapshots/#{identity}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_database_server_snapshot(params={})
      response(
        :body => {"database_server_snapshot" => self.find(:database_server_snapshots, resource_identity(params))},
      )
    end
  end
end

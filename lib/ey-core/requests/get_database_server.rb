class Ey::Core::Client
  class Real
    def get_database_server(params={})
      id = params["id"]
      url = params["url"]

      request(
        :path => "/database-servers/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_database_server(params={})
      response(
        :body => { "database_server" => self.find(:database_servers, resource_identity(params)) },
      )
    end
  end
end

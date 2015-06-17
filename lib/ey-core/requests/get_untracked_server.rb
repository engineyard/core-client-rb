class Ey::Core::Client
  class Real
    def get_untracked_server(params={})
      request(
        :path => "/untracked-servers/#{params.fetch("id")}",
        :url  => params.delete("url"),
      )
    end
  end # Real

  class Mock
    def get_untracked_server(params={})
      response(
        :body => {"untracked_server" => self.find(:untracked_servers, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

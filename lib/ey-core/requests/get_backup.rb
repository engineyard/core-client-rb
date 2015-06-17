class Ey::Core::Client
  class Real
    def get_backup(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "backups/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_backup(params={})
      response(
        :body => {"backup" => self.find(:backups, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

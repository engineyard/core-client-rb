class Ey::Core::Client
  class Real
    def get_backup_file(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "backup_files/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_backup_file(params={})
      response(
        :body   => {"backup_file" => self.find(:backup_files, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

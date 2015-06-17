class Ey::Core::Client
  class Real
    def finish_backup(params={})
      id  = params["id"]

      request(
        :path   => "backups/#{id}/finish",
        :method => :put,
      )
    end
  end # Real

  class Mock
    def finish_backup(params={})
      backup = find(:backups, resource_identity(params))

      backup["finished_at"] ||= Time.now
      backup["finished"] = true

      response(
        :body   => {"backup" => backup},
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client

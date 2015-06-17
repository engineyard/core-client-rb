class Ey::Core::Client
  class Real
    def update_application_archive(params={})
      id             = params.delete("id")
      application_id = params["application"]
      request(
        :method => :put,
        :path   => "/applications/#{application_id}/archives/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_application_archive(params={})
      archive = self.find(:application_archives, resource_identity(params))

      response(
        :body => {"application_archive" => archive.merge(params["application_archive"])},
      )
    end
  end
end

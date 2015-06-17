class Ey::Core::Client
  class Real
    def create_application_archive(params={})
      application_id = params["application"]
      url            = params.delete("url")

      request(
        :method => :post,
        :path   => "/applications/#{application_id}/archives",
        :params => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_application_archive(params={})
      resource_id    = self.uuid
      url            = params.delete("url")
      application_id = Integer(params["application"] || (url && path_params(url)["applications"]))

      find(:applications, application_id)

      resource = params["application_archive"].dup

      resource.merge!(
        "id"                => resource_id,
        "application"       => url_for("/applications/#{application_id}"),
        "created_at"        => Time.now,
        "updated_at"        => Time.now,
        "upload_successful" => false,
        "upload_url"        => "http://example.org/#{resource_id}",
        "url"               => "http://example.org/#{resource_id}",
      )

      self.data[:application_archives][resource_id] = resource

      response(
        :body   => {"application_archive" => resource},
        :status => 201,
      )
    end
  end
end

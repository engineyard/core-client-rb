class Ey::Core::Client
  class Real
    def get_application_archive(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path => "/application-archives/#{id}",
        :url  => url
      )
    end
  end # Real

  class Mock
    def get_application_archive(params={})
      if params.is_a? String
        params = {"url" => params}
      end

      url            = params.delete("url")
      application_id = params["application"] || (url && path_params(url)["applications"])
      resource_id    = params["id"] || (url && path_params(url)["archives"])

      find(:applications, application_id)

      response(
        :body   => {"application_archive" => find(:application_archives, resource_id)},
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client

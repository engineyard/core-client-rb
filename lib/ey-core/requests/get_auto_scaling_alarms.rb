class Ey::Core::Client
  class Real
    def get_auto_scaling_alarms(params = {})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/auto_scaling_alarms",
        :query  => params,
        :url    => url,
      )
    end
  end

  class Mock
    def get_auto_scaling_alarms(params = {})
      extract_url_params!(params)

      headers, auto_scaling_alarms_page = search_and_page(
        params,
        :auto_scaling_alarms,
        search_keys: %w{ id auto_scaling_policy },
        resources: data[:auto_scaling_alarms]
      )

      response(
        :body    => { "auto_scaling_alarms" => auto_scaling_alarms_page },
        :status  => 200,
        :headers => headers
      )
    end
  end
end

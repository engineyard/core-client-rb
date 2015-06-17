class Ey::Core::Client
  class Real
    def get_legacy_alerts(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/legacy-alerts",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_legacy_alerts(params={})
      extract_url_params!(params)

      headers, alerts_page = search_and_page(params, :legacy_alerts, search_keys: %w[environment server severity assigned acknowledged])

      response(
        :body    => {"legacy_alerts" => alerts_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

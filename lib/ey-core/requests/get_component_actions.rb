class Ey::Core::Client
  class Real
    def get_component_actions(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/component-actions",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_component_actions(params={})
      extract_url_params!(params)

      headers, component_actions_page = search_and_page(params, :component_actions, search_keys: %w[task])

      response(
        :body    => {"component_actions" => component_actions_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

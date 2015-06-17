class Ey::Core::Client
  class Real
    def get_tasks(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :query => query,
        :path  => "/tasks",
        :url   => url,
      )
    end
  end # Real
  class Mock
    def get_tasks(params={})
      extract_url_params!(params)

      headers, tasks_page = search_and_page(params, :tasks, search_keys: %w[cluster_component])

      response(
        :body    => {"tasks" => tasks_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

class Ey::Core::Client
  class Real
    def get_requests(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :path   => "/requests",
        :url    => url,
        :params => params,
        :query  => query,
      )
    end
  end # Real

  class Mock
    def get_requests(params={})
      extract_url_params!(params)

      headers, requests_page = search_and_page(params, :requests, search_keys: %w[type finished_at requester_id])

      response(
        :body    => {"requests" => requests_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

class Ey::Core::Client
  class Real
    def get_compute_flavors(params={})
      query       = Ey::Core.paging_parameters(params)
      url         = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_compute_flavors(params={})
      extract_url_params!(params)

      #TODO: return something useful

      response(
        :body    => {"compute_flavors" => []},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

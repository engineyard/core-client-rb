class Ey::Core::Client
  class Real
    def get_memberships(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :url    => params.delete("url"),
        :path   => "/memberships",
        :params => params,
        :query  => query,
      )
    end
  end # Real

  class Mock
    def get_memberships(params={})
      extract_url_params!(params)

      headers, memberships_page = page(params, :memberships)

      response(
        :body    => {"memberships" => memberships_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end

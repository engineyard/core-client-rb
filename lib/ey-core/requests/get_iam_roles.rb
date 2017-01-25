class Ey::Core::Client
  class Real
    def get_iam_roles(options={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/iam_roles",
        :url    => url,
      )
    end
  end
end

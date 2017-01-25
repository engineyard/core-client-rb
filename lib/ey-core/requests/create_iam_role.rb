class Ey::Core::Client
  class Real
    def create_iam_role(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/iam_roles",
        :url    => url,
        :body   => params
      )
    end
  end
end

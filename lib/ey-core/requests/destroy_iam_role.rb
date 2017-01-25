class Ey::Core::Client
  class Real
    def destroy_iam_role(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/iam_roles/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end
end

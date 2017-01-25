class Ey::Core::Client
  class Real
    def get_iam_role(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "iam_roles/#{id}",
        :url  => url,
      )
    end
  end
end

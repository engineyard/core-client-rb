class Ey::Core::Client
  class Real
    def get_auto_scaling_policy(params = {})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :get,
        :path   => "auto_scaling_policies/#{id}",
        :url    => url
      )
    end
  end

  class Mock
    def get_auto_scaling_policy(params = {})
      response(
        :body => {
          "auto_scaling_policy" => self.find(
            :auto_scaling_policies,
            resource_identity(params)
          )
        },
      )
    end
  end
end

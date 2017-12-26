class Ey::Core::Client
  class Real
    def update_auto_scaling_policy(params = {})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "/auto_scaling_policies/#{id}",
        :body   => { "auto_scaling_policy" => params.fetch("auto_scaling_policy") },
      )
    end
  end

  class Mock
    def update_auto_scaling_policy(params = {})
      resource_id = params.delete("id")
      resource = find(:auto_scaling_policies, resource_id)
        .merge(params["auto_scaling_policy"])
        .merge("updated_at" => Time.now)
      resource.merge!(params)

      response(
        :body   => { "auto_scaling_policy" => resource },
        :status => 200
      )
    end
  end
end

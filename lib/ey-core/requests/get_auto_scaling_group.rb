class Ey::Core::Client
  class Real
    def get_auto_scaling_group(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "auto_scaling_groups/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_auto_scaling_group(params={})
      response(
        :body => {"auto_scaling_group" => self.find(:auto_scaling_groups, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

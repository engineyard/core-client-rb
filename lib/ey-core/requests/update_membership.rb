class Ey::Core::Client
  class Real
    def update_membership(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/memberships/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_membership(params={})
      resource_id = resource_identity(params)

      membership = self.find(:memberships, resource_id)
      if params["membership"] && params["membership"]["accepted"]
        self.find(:accounts, resource_identity(membership["account"]))[:account_users] << resource_identity(membership["user"])
      end

      #NOTE: doesn't currently support updating role
      response(
        :body   => {"membership" => membership},
        :status => 200,
      )
    end
  end
end

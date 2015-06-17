class Ey::Core::Client
  class Real
    def create_membership(params={})
      query_params = {"membership" => params["membership"]}
      body = query_params.to_json

      request(
        :method => :post,
        :path   => "/memberships",
        :body => body
      )
    end
  end # Real

  class Mock
    def create_membership(params={})
      id = self.uuid
      membership = {
        "id"      => id,
        "account" => url_for("/accounts/"+params["membership"]["account"]),
        "user"    => url_for("/users/"+params["membership"]["user"]),
        "role"    => params["membership"]["role"],
        #NOTE missing attributes: email, created_at, updated_at, deleted_at, requester_url
        #also "implied" attribute: accepted = false
      }
      self.data[:memberships][id] = membership
      response(
        :body => {"membership" => membership},
        :status => 201
      )
    end
  end # Mock
end

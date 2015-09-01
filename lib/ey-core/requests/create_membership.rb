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

      requester_id = @current_user && @current_user["id"]

      membership = {
        "id"           => id,
        "account"      => url_for("/accounts/"+params["membership"]["account"]),
        "requester"    => url_for("/users/"+requester_id),
        "role"         => params["membership"]["role"],
        "email"        => params["membership"]["email"],
        "redirect_url" => params["membership"]["redirect_url"]
        #NOTE missing attributes:, created_at, updated_at, deleted_at, requester_url
        #also "implied" attribute: accepted = false
      }

      if params["membership"]["user"]
        user = find(:users, params["membership"]["user"])
        membership.merge!({
          "user"  => url_for("/users/"+user["id"]),
          "email" => user["email"],
        })
      end

      self.data[:memberships][id] = membership
      response(
        :body => {"membership" => membership},
        :status => 201
      )
    end
  end # Mock
end

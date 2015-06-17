require 'securerandom'
class Ey::Core::Client
  class Real
    def create_user(params={})
      request(
        :method => :post,
        :path   => "/users",
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_user(params={})
      if self.authentication != :hmac
        response(status: 403)
      end

      if self.data[:users].map{ |_, user| user["email"] }.include?(params["user"]["email"])
        response(
          :status => 422,
          :body => {
            :errors => ["Email has already been taken"]
          }
        )
      end

      resource_id = self.uuid

      resource = params["user"].dup
      resource["token"] = SecureRandom.hex(20)

      resource.merge!({
        "id"          => resource_id,
        "accounts"    => url_for("/users/#{resource_id}/accounts"),
        "memberships" => url_for("/users/#{resource_id}/memberships"),
        "keypairs"    => url_for("/users/#{resource_id}/keypairs"),
      })

      self.data[:users][resource_id] = resource

      response(
        :body    => {"user" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

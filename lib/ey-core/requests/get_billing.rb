class Ey::Core::Client
  class Real
    def get_billing(params={})
      id  = params["id"]
      request(
        :path => "accounts/#{id}/billing",
      )
    end
  end # Real

  class Mock
    def get_billing(params={})
      identity = resource_identity(params)

      self.find(:accounts, identity)

      state = self.data[:billing][identity] || "requested"
      response(
        :body   => {"billing" => {"id" => identity, "state" => state}},
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client

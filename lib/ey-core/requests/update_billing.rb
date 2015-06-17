class Ey::Core::Client
  class Real
    def update_billing(params={})
      id = params.delete("id") or raise "ID needed"
      request(
        :method => :put,
        :path   => "/accounts/#{id}/billing",
        :params => params,
      )
    end
  end # Real

  class Mock
    def update_billing(params={})
      id = params["id"]
      state = params["state"]
      self.find(:accounts, id)

      self.data[:billing][id] = state

      response(
        :body => {"billing" => {"id" => id, "state" => state}},
      )
    end
  end # Mock
end # Ey::Core::Client

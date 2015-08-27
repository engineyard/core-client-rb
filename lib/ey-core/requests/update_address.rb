class Ey::Core::Client
  class Real
    def update_address(params={})
      id = params["id"]

      request(
        :method => :put,
        :path   => "addresses/#{id}",
        :body   => {"address" => params.fetch("address")}
      )
    end
  end # Real

  class Mock
    def update_address(params={})
      identity = resource_identity(params)
      address  = find(:addresses, identity)

      address_params = Cistern::Hash.slice(Cistern::Hash.stringify_keys(params["address"]), "disappeared_at")

      address.merge! address_params

      response(
        :body => { "address" => address },
        :status => 200
      )
    end
  end # Mock
end # Ey::Core::Client

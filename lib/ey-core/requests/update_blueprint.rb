class Ey::Core::Client
  class Real
    def update_blueprint(params={})
      id = params.delete("id")

      request(
        :path   => "blueprints/#{id}",
        :body   => params,
        :method => :put
      )
    end
  end

  class Mock
    def update_blueprint(params={})
      params           = Cistern::Hash.stringify_keys(params)
      blueprint_params = params["blueprint"]
      blueprint        = find(:blueprints, params["id"])

      blueprint["name"] = blueprint_params["name"]
      self.data[:blueprints][blueprint["id"]] = blueprint

      response(
        :body   => {"blueprint" => blueprint},
        :status => 200,
      )
    end
  end
end

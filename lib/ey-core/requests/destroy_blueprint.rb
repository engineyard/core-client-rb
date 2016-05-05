class Ey::Core::Client
  class Real
    def destroy_blueprint(params={})
      id = params.delete("id")

      request(
        :path   => "blueprints/#{id}",
        :method => :delete
      )
    end
  end

  class Mock
    def destroy_blueprint(params={})
      blueprint = find(:blueprints, params["id"])

      self.data[:blueprints].delete(blueprint["id"])

      response(status: 204)
    end
  end
end

class Ey::Core::Client
  class Real
    def get_blueprint(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :path => "blueprints/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_blueprint(params={})
      response(
        :body => {"blueprint" => self.find(:blueprints, resource_identity(params))}
      )
    end
  end
end

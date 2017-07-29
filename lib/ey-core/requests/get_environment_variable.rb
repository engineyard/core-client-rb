class Ey::Core::Client
  class Real
    def get_environment_variable(params={})
      id  = params.delete("id")
      url = params.delete("url")

      request(
        :path => "environment_variables/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_environment_variable(params={})
      response(body: {"environment_variable" => find(:environment_variables, resource_identity(params))})
    end
  end
end

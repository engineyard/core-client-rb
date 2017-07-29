class Ey::Core::Client
  class Real
    def update_environment_variable(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      id = params.delete("id")
      body = { environment_variable: params }

      request(
        :method => :put,
        :path   => "/environment_variables/#{id}",
        :body   => body
      )
    end
  end

  class Mock
    def update_environment_variable(_params={})
      params = Cistern::Hash.stringify_keys(_params).merge!("updated_at" => Time.now)
      environment_variable  = find(:environment_variables, params.delete("id"))
      environment_variable.merge!(params)

      response(:body => { "environment_variable" => environment_variable })
    end
  end
end

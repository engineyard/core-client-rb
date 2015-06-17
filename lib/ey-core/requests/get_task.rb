class Ey::Core::Client
  class Real
    def get_task(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "/tasks/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_task(params={})
      response(
        :body => {"task" => self.find(:tasks, resource_identity(params))},
      )
    end
  end # Mock
end # Ey::Core::Client

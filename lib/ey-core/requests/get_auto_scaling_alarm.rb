class Ey::Core::Client
  class Real
    def get_auto_scaling_alarm(params = {})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :get,
        :path   => "auto_scaling_alarms/#{id}",
        :url    => url
      )
    end
  end

  class Mock
    def get_auto_scaling_alarm(params = {})
      response(
        :body => {
          "auto_scaling_alarm" => self.find(
            :auto_scaling_alarms,
            resource_identity(params)
          )
        },
      )
    end
  end
end

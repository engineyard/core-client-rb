class Ey::Core::Client
  class Real
    def get_message(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "messages/#{id}",
        :url  => url
      )
    end
  end

  class Mock
    def get_message(params={})
      identity = resource_identity(params)

      if message = self.data[:messages].values.detect { |m| m["id"] == identity }
        response(
          :body   => {"message" => message},
          :status => 200,
        )
      else
        response(status: 404)
      end
    end
  end
end

class Ey::Core::Client
  class Real
    def get_account_cancellation(params={})
      url = params["url"]
      request(
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_account_cancellation(params={})
      identity = resource_identity(params)

      cancellation = self.find(:account_cancellations, identity)
      response(
        :body => {"cancellation" => cancellation},
      )
    end
  end # Mock
end # Ey::Core::Client

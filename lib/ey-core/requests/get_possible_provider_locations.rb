class Ey::Core::Client
  class Real
    def get_possible_provider_locations(type)
      request(
        :path => "/providers/#{type}/locations"
      )
    end
  end

  class Mock
    def get_possible_provider_locations(type)
      response(
        :body    => {"locations" => self.data[:possible_provider_locations][type]},
        :status  => 200,
        :headers => {},
      )
    end
  end
end

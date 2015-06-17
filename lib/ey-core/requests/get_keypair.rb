class Ey::Core::Client
  class Real
    def get_keypair(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "keypairs/#{id}",
        :url  => url,
      )
    end
  end  #  Real

  class Mock
    def get_keypair(params={})
      response(
        :body => {"keypair" => self.find(:keypairs, resource_identity(params))},
      )
    end
  end  #  Mock
end  #  Ey::Core::Client

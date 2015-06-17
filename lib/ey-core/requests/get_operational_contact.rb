class Ey::Core::Client
  class Real
    def get_operational_contact(params={})
      id = params["id"]
      url = params["url"]

      request(
        :path => "/contacts/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_operational_contact(params={})
      #response(
        #:body => { "contact" => self.find(:operational_contacts, resource_identity(params)) },
      #)
    end
  end
end

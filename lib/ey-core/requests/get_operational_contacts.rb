class Ey::Core::Client
  class Real
    def get_operational_contacts(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/contacts",
        :url    => url,
      )
    end
  end

  class Mock
    def get_operational_contacts(params={})
    end
  end
end

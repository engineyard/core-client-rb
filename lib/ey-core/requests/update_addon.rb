class Ey::Core::Client
  class Real
    def update_addon(params={})
      url = params.delete("url") or raise "URL needed"
      request(
        :method => :put,
        :url    => url,
        :params => params,
      )
    end
  end # Real

  class Mock
    def update_addon(params={})
      addon = params["addon"]

      extract_url_params!(params)

      find(:accounts, params["account"])

      resource = self.find(:addons, params["addon"])

      response(
        :body => {"addon" => resource.merge!(addon) },
      )
    end
  end # Mock
end # Ey::Core::Client

class Ey::Core::Client
  class Real
    def get_addon(params={})
      url   = params.delete("url") or raise "URL needed"
      request(
        :params => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_addon(params={})
      extract_url_params!(params)

      self.find(:accounts, params["account"])

      addon = self.find(:addons, params["addon"])

      response(
        :body => {"addon" => addon},
      )
    end
  end # Mock
end

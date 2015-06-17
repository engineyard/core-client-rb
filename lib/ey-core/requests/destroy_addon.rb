class Ey::Core::Client
  class Real
    def destroy_addon(params={})
      url = params.delete("url") or raise "URL needed"
      request(
        :method => :delete,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def destroy_addon(params={})
      extract_url_params!(params)

      find(:accounts, params["account"])

      addon = find(:addons, params["addon"])
      addon["deleted_at"] = Time.now

      response(status: 204)
    end
  end # Mock
end # Ey::Core::Client

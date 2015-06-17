class Ey::Core::Client
  class Real
    def get_addon_attachments(params={})
      if account_id = params["account_id"]
        params["url"] = "/accounts/#{account_id}/attachments"
      end
      url = params.delete("url") or raise "URL needed"
      request(
        :params => params,
        :path   => url,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def get_addon_attachments(params={})
      if account_id = params.delete("account_id")
        params["url"] = "/accounts/#{account_id}/attachments"
      end

      extract_url_params!(params)

      account = find(:accounts, params["account"])
      addon = find(:addons, params["addon"]) rescue nil

      found_attachments = load_addon_attachments(account["id"], addon && addon["name"])

      if addon
        found_attachments.select! {|a| a["key"] }
      end

      response(
        :body    => {"addon_attachments" => found_attachments},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end

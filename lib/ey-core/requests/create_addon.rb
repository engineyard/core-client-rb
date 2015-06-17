class Ey::Core::Client
  class Real
    def create_addon(params={})
      url = params.delete("url") or raise "URL needed"
      request(
        :method => :post,
        :url    => url,
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_addon(params={})
      url        = params.delete("url") or raise "URL needed"
      account_id = path_params(url)["accounts"] or raise "Need account id, not parsed from #{url}"

      resource_id = self.serial_id

      resource = params["addon"].merge(
        "id"                 => resource_id,
        "addon_attachments"  => url_for("/accounts/#{account_id}/addons/#{resource_id}/attachments"),
        "account"            => url_for("/accounts/#{account_id}"),
        "vars"               => normalize_hash(params["addon"]["vars"] || {}),
      )

      self.data[:addons][resource_id] = resource

      response(
        :body    => {"addon" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

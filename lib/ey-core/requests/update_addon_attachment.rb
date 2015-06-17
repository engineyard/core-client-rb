class Ey::Core::Client
  class Real
    def update_addon_attachment(params={})
      url = params.delete("url") or raise "URL needed"
      request(
        :method => :put,
        :url    => url,
        :params => params,
      )
    end
  end # Real

  class Mock
    def update_addon_attachment(params={})
      updated = params["attachment"]

      extract_url_params!(params)

      account = find(:accounts, params["account"])
      addon   = find(:addons, params["addon"])

      attachment_id = resource_identity(params["attachment"])
      key           = updated["key"]

      found_attachments = load_addon_attachments(account["id"], addon["name"])
      attachment        = found_attachments.detect{|attachment| attachment['id'] == attachment_id}

      cluster_component_id = attachment["id"].match(/\AClusterComponent:(.+)\Z/)[1]
      cluster_component = find(:cluster_components, cluster_component_id)
      cluster_component["configuration"]["vars"] ||= {}

      old_key,_ = cluster_component["configuration"]["vars"].detect{|k,v| v == "Addon:#{addon['name']}"}
      if old_key
        if deleted = cluster_component["configuration"]["vars"].delete(old_key)
          connector_id,_ = self.data[:connectors].detect do |key, c|
            (c["source"] == url_for("/accounts/#{account["id"]}/addons/#{addon["id"]}")) &&
            (c["configuration"]["key"] == old_key)
          end
          self.data[:connectors].delete(connector_id)
        end
      end

      if key
        cluster_component["configuration"]["vars"][key] = "Addon:#{addon['name']}"
        new_connector_id                          = self.uuid
        self.data[:connectors][new_connector_id]  = {
          "destination"   => url_for("/cluster-components/#{cluster_component["id"]}"),
          "source"        => url_for("/accounts/#{account["id"]}/addons/#{addon["id"]}"),
          "id"            =>  new_connector_id,
          "configuration" => {"key" => key},
        }
      end

      response(
        :body    => {"addon_attachment" => attachment},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client

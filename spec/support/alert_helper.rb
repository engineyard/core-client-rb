module LegacyAlertHelper
  def create_legacy_alert(client, attributes={})
    attributes = Cistern::Hash.stringify_keys(attributes)

    if server = attributes.delete("server")
      attributes["server"] = client.url_for("/servers/#{server.id}")
    end
    client.data[:legacy_alerts][attributes["id"]] = attributes
  end
end

RSpec.configure do |config|
  config.include(LegacyAlertHelper)
end

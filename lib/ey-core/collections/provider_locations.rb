class Ey::Core::Client::ProviderLocations < Ey::Core::Collection

  model Ey::Core::Client::ProviderLocation

  self.model_root         = "provider_location"
  self.model_request      = :get_provider_location
  self.collection_root    = "provider_locations"
  self.collection_request = :get_provider_locations

  def discover(location_id)
    connection.requests.new(self.connection.discover_provider_location(self.url, location_id).body["request"])
  end
end

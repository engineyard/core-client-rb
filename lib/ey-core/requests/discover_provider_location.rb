class Ey::Core::Client
  class Real
    def discover_provider_location(url, location_id)
      id          = url.split("/")[-2]
      location_id = URI.escape(location_id)

      request(
        :method => :put,
        :path   => "/providers/#{id}/locations/#{location_id}/discover",
      )
    end
  end

  class Mock
    def discover_provider_location(url, location_id)
      resource_id = self.uuid
      request_id  = self.uuid
      provider_id = url.split("/")[-2]
      provider    = self.data[:providers][provider_id.to_i]
      type        = provider["type"]

      possible_location = self.data[:possible_provider_locations][type].detect { |l| l["id"] == location_id }

      resource = {
        "id"            => resource_id,
        "provider"      => url_for("/providers/#{provider_id}"),
        "location_id"   => location_id,
        "location_name" => possible_location["name"],
        "resource_url"  => "/provider_locations/#{resource_id}"
      }

      self.data[:provider_locations][resource_id] = resource

      request = {
        "id"          => request_id,
        "type"        => "discover_provider_location",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:provider_locations, resource_id, resource],
      }

      self.data[:requests][request_id] = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end
end

class Ey::Core::Client
  class Real
    def create_provider(params={})
      if account_id = params["account"]
        request(
          :method => :post,
          :path   => "/accounts/#{account_id}/providers",
          :body   => params,
        )
      elsif url = params.delete("url")
        request(
          :method => :post,
          :url    => url,
          :body   => params,
        )
      else
        raise "Need params for either Account ID (account) or URL"
      end
    end
  end # Real

  class Mock
    def create_provider(params={})
      resource_id    = self.serial_id
      request_id     = self.uuid
      account_id     = params["account"]
      url            = params.delete("url")

      account_id ||= url && path_params(url)["accounts"]

      find(:accounts, account_id)

      provider_params = params["provider"]

      provider = {
        "account"            => url_for("/accounts/#{account_id}"),
        "id"                 => resource_id,
        "resource_url"       => url_for("/providers/#{resource_id}"),
        "provider_locations" => url_for("/providers/#{resource_id}/locations"),
        "storages"           => url_for("/providers/#{resource_id}/storages"),
        "servers"            => url_for("/providers/#{resource_id}/servers"),
        "untracked_servers"  => url_for("/providers/#{resource_id}/untracked-servers"),
        "provisioned_id"     => provider_params["provisioned_id"] || SecureRandom.uuid,
        "created_at"         => Time.now,
        "updated_at"         => Time.now,
        "type"               => provider_params["type"].to_s,
        "credentials"        => provider_params["credentials"],
        "shared"             => provider_params.fetch(:shared, false),
      }

      unless ["aws", "azure"].include?(provider["type"])
        response(status: 422, body: {"errors" => ["Unknown provider type: #{provider["type"]}"]})
      end

      self.data[:possible_provider_locations][provider["type"].to_s].each do |location|
        provider_location_id = self.uuid
        provider_location = {
          "id"          => provider_location_id,
          "location_id" => location["id"],
          "provider"    => url_for("/providers/#{resource_id}"),
          "name"        => location["name"],
          "data"        => {},
        }
        self.data[:provider_locations][provider_location_id] = provider_location
      end

      request = provider.merge(
        "resource"    => [:providers, resource_id, provider],
        "type"        => "provider",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => "true",
        "id"          => request_id,
      )

      self.data[:requests][request_id]   = request

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client

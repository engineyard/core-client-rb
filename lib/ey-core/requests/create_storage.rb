class Ey::Core::Client
  class Real
    def create_storage(params={})
      provider_id = params.delete("provider")
      url         = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/providers/#{provider_id}/storages",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_storage(params={})
      extract_url_params!(params)

      request_id  = self.uuid
      resource_id = self.uuid

      provider_id  = resource_identity(params["provider"])
      provider_url = url_for("/providers/#{provider_id}")

      provider = find(:providers, provider_id)

      resource = params["storage"].dup

      resource.merge!({
        "id"                => resource_id,
        "name"              => resource["name"],
        "location"          => resource["location"],
        "provisioned_id"    => self.uuid,
        "provider"          => provider_url,
        "storage_users_url" => url_for("/storages/#{resource_id}"),
        "resource_url"      => "/storages/#{resource_id}"
      })

      request = {
        "id"          => request_id,
        "type"        => "provision_provider_storage",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:storages, resource_id, resource],
      }

      self.data[:requests][request_id]  = request
      self.data[:storages][resource_id] = resource

      response_hash = request.dup
      response_hash.delete("resource")

      response(
        :body    => {"request" => response_hash},
        :status  => 201,
        :headers => {
          "Content-Type" => "application/json; charset=utf8",
        }
      )
    end
  end # Mock
end

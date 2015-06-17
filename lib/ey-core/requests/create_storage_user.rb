class Ey::Core::Client
  class Real
    def create_storage_user(params={})
      storage_id = params.delete("storage")
      url        = params.delete("url")

      request(
        :body   => params,
        :method => :post,
        :path   => "/storages/#{storage_id}/users",
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_storage_user(params={})
      extract_url_params!(params)

      request_id  = self.uuid
      resource_id = self.uuid

      storage_id  = resource_identity(params["storage"])
      storage_url = url_for("/storages/#{storage_id}")

      storage = find(:storages, storage_id)

      resource = params["storage_user"].dup

      resource.merge!({
        "id"             => resource_id,
        "username"       => resource["username"],
        "provisioned_id" => self.uuid,
        "access_id"      => SecureRandom.hex(16),
        "secret_key"     => SecureRandom.hex(32),
        "storage"        => storage_url,
        "resource_url"   => "/storages/#{storage_id}/storage-users/#{resource_id}"
      })

      request = {
        "id"          => request_id,
        "type"        => "provision_provider_storage_credential",
        "successful"  => true,
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:storage_users, resource_id, resource],
      }

      self.data[:requests][request_id]  = request
      self.data[:storage_users][resource_id] = resource

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

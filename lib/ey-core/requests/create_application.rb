class Ey::Core::Client
  class Real
    def create_application(params={})
      url = params.delete("url")

      request(
        :method => :post,
        :path   => "/applications",
        :params => params,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def create_application(params={})
      resource_id  = self.serial_id
      url          = params.delete("url")

      account_id = params["account"] || url && path_params(url)["accounts"]

      find(:accounts, account_id)

      resource = params["application"].dup

      resource.merge!(
        "account"    => url_for("/accounts/#{account_id}"),
        "archives"   => url_for("/applications/#{resource_id}/archives"),
        "keypairs"   => url_for("/applications/#{resource_id}/keypairs"),
        "created_at" => Time.now,
        "updated_at" => Time.now,
        "id"         => resource_id,
      )

      key = mock_ssh_key

      keypair = {
        "id"          => self.serial_id,
        "application" => url_for("/applications/#{resource_id}"),
        "user"        => nil,
        "fingerprint" => key[:fingerprint],
        "public_key"  => key[:public_key],
        "private_key" => key[:private_key],
      }

      self.data[:keypairs][keypair['id']] = keypair
      self.data[:applications][resource_id] = resource

      response(
        :body   => {"application" => resource},
        :status => 201,
      )
    end
  end
end

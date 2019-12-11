class Ey::Core::Client
  class Real
    def create_account(params={})
      request(
        :method => :post,
        :path   => "/accounts",
        :params => params,
      )
    end
  end # Real

  class Mock
    def create_account(params={})
      resource_id = self.uuid
      owner_id    = params["owner"] || @current_user && @current_user["id"]

      find(:users, owner_id)

      if name_prefix = params["account"].delete("name_prefix")
        params["account"]["name"] = "#{name_prefix}-#{resource_id[0,4]}"
      end

      resource = mock_account_setup(resource_id, params["account"].dup)

      self.data[:accounts][resource_id] = resource.merge(:account_users => [owner_id], :account_owners => [owner_id])

      resource.merge!(
        :environments_url => url_for("/accounts/#{resource_id}/environments"),
        :applications_url => url_for("/accounts/#{resource_id}/applications")
      )

      response(
        :body    => {"account" => resource},
        :status  => 201,
      )
    end
  end # Mock
end # Ey::Core::Client

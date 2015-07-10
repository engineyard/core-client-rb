class Ey::Core::Client
  class Real
    def get_database_services(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/database-services",
        :url    => url,
      )
    end
  end

  class Mock
    def get_database_services(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      extract_url_params!(params)

      if provider_id = resource_identity(params.delete("provider"))
        params["provider"] = url_for("/providers/#{provider_id}")
      end

      if account_id = resource_identity(params.delete("account"))
        if provider = self.data[:providers].values.detect{|p| p["account"].index(account_id)}
          params["provider"] = url_for("/providers/#{provider["id"]}")
        end
      end

      resources = if environment_id = resource_identity(params.delete("environment") || params.delete("environment_id"))
                    self.data[:connectors].
                      select { |_,c| c["_environment"] == url_for("/environments/#{environment_id}") }.
                      select { |_,c| c["source"].match("logical-databases") }.
                      inject({}) { |r, (_, connector)|
                        logical_database = self.find(:logical_databases,
                                                     resource_identity(connector["source"]))

                        source_id = resource_identity(logical_database["service"])
                        database_service = self.find(:database_services, source_id)

                        r.merge(source_id => database_service)
                    }
                  end

      headers, database_services_page = search_and_page(params, :database_services, search_keys: %w[provider name], resources: resources)

      response(
        :body    => {"database_services" => database_services_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end

class Ey::Core::Client
  class Real
    def get_firewalls(params={})
      query = Ey::Core.paging_parameters(params)
      url = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/firewalls",
        :url    => url,
      )
    end
  end

  class Mock
    def get_firewalls(params={})
      extract_url_params!(params)

      if server_url = params.delete("server")
        params.merge!("cluster" => resource_identity(self.find(:servers, server_url)["cluster"]))
      end

      resources = if database_server_url = params.delete("database_server")
                    database_server_id = resource_identity(database_server_url)
                    firewall_ids = self.data[:database_server_firewalls].inject([]) { |r, (ds, f)| (ds == database_server_id) ? r << f : r }
                    firewall_ids.inject({}) { |r, id| r.merge(id => self.data[:firewalls][id]) }
                  elsif cluster_url = params.delete("cluster")
                    cluster_id = resource_identity(cluster_url)
                    firewall_ids = self.data[:cluster_firewalls].inject([]) { |r, (c, f)| (c == cluster_id) ? r << f : r }
                    firewall_ids.inject({}) { |r, id| r.merge(id => self.data[:firewalls][id]) }
                  else
                    self.data[:firewalls]
                  end

      headers, firewalls_page = search_and_page(params, :firewalls, search_keys: %w[provisioned_id name], resources: resources)

      response(
        :body    => {"firewalls" => firewalls_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end

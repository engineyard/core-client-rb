class Ey::Core::Client
  class Real
    def get_firewall_rules(params={})
      query       = Ey::Core.paging_parameters(params)
      url         = params.delete("url")

      request(
        :params => params,
        :query  => query,
        :path   => "/firewall-rules",
        :url    => url,
      )
    end
  end

  class Mock
    def get_firewall_rules(params={})
      extract_url_params!(params)

      headers, firewall_rules_page = search_and_page(params, :firewall_rules, search_keys: %w[firewall port_range source])

      response(
        :body    => {"firewall_rules" => firewall_rules_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end

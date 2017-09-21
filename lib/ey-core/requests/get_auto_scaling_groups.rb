class Ey::Core::Client
  class Real
    def get_auto_scaling_groups(options={})
      query = Ey::Core.paging_parameters(options)
      url   = options.delete("url")

      request(
        :params => options,
        :query  => query,
        :path   => "/auto_scaling_groups",
        :url    => url,
      )
    end
  end

  class Mock
    def get_auto_scaling_groups(options={})
      extract_url_params!(options)

      headers, auto_scaling_groups_page = search_and_page(options, :auto_scaling_groups, search_keys: %w[environment environment_id account account_id provider provider_id provisioned_id])

      response(
        :body    => {"auto_scaling_groups" => auto_scaling_groups_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end

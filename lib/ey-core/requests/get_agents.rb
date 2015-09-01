class Ey::Core::Client::GetAgents < Cistern::Request
  include Ey::Core::Request

  service Ey::Core::Client

  def real
    request(
      :params => params,
      :query  => Ey::Core.paging_parameters(params),
      :path   => "/agents",
      :url    => params.delete("url"),
    )
  end

  def mock
    extract_url_params!(params)

    if params["deis_cluster"]
      params["cluster"] = params.delete("deis_cluster")
    end

    headers, deis_clusters_page = search_and_page(params, :agents, search_keys: %w[host cluster])

    response(
      :body    => {"agents" => deis_clusters_page},
      :status  => 200,
      :headers => headers
    )
  end
end

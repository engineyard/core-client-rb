class Ey::Core::Client::GetDeisClusters < Cistern::Request
  include Ey::Core::Request

  service Ey::Core::Client

  def real
    request(
      :params => params,
      :query  => Ey::Core.paging_parameters(params),
      :path   => "/deis-clusters",
      :url    => params.delete("url"),
    )
  end

  def mock
    extract_url_params!(params)

    headers, deis_clusters_page = search_and_page(params, :deis_clusters, search_keys: %w[account name])

    response(
      :body    => {"deis_clusters" => deis_clusters_page},
      :status  => 200,
      :headers => headers
    )
  end
end

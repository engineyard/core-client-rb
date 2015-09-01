class Ey::Core::Client::GetDeisCluster < Cistern::Request
  include Ey::Core::Request

  service Ey::Core::Client

  def real
    params["url"] || (id = params.fetch("id"))

    request(
      :path => "/deis-clusters/#{id}",
      :url  => params["url"],
    )
  end

  def mock
    response(
      :body => {"deis_cluster" => self.find(:deis_clusters, resource_identity(params))},
    )
  end
end # Mock

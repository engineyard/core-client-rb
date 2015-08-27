class Ey::Core::Client::DeisClusters < Ey::Core::Collection
  model Ey::Core::Client::DeisCluster

  self.model_root         = "deis_cluster"
  self.model_request      = :get_deis_cluster
  self.collection_root    = "deis_clusters"
  self.collection_request = :get_deis_clusters
end

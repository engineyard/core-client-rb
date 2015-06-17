class Ey::Core::Client::Clusters < Ey::Core::Collection

  model Ey::Core::Client::Cluster

  self.model_root         = "cluster"
  self.model_request      = :get_cluster
  self.collection_root    = "clusters"
  self.collection_request = :get_clusters
end

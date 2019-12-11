class Ey::Core::Client::ContainerClusters < Ey::Core::Collection

  model Ey::Core::Client::ContainerCluster

  self.model_root         = "container_cluster"
  self.model_request      = :get_container_cluster
  self.collection_root    = "container_clusters"
  self.collection_request = :get_container_clusters
end

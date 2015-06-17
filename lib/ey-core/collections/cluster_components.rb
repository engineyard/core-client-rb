class Ey::Core::Client::ClusterComponents < Ey::Core::Collection

  model Ey::Core::Client::ClusterComponent

  self.model_root         = "cluster_component"
  self.model_request      = :get_cluster_component
  self.collection_root    = "cluster_components"
  self.collection_request = :get_cluster_components
end

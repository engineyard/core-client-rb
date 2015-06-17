class Ey::Core::Client::ClusterUpdates < Ey::Core::Collection

  model Ey::Core::Client::ClusterUpdate

  self.collection_request = :get_cluster_updates
  self.collection_root    = "cluster_updates"
  self.model_request      = :get_cluster_update
  self.model_root         = "cluster_update"
end

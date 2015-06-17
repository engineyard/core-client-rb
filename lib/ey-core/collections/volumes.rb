class Ey::Core::Client::Volumes < Ey::Core::Collection

  model Ey::Core::Client::Volume

  self.model_root         = "volume"
  self.model_request      = :get_volume
  self.collection_root    = "volumes"
  self.collection_request = :get_volumes
end

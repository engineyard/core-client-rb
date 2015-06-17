class Ey::Core::Client::Storages < Ey::Core::Collection

  model Ey::Core::Client::Storage

  self.model_root         = "storage"
  self.model_request      = :get_storage
  self.collection_root    = "storages"
  self.collection_request = :get_storages
end

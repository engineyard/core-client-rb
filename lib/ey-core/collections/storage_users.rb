class Ey::Core::Client::StorageUsers < Ey::Core::Collection

  model Ey::Core::Client::StorageUser

  self.model_root         = "storage_user"
  self.model_request      = :get_storage_user
  self.collection_root    = "storage_users"
  self.collection_request = :get_storage_users
end


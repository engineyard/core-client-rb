class Ey::Core::Client::ServerUsages < Ey::Core::Collection

  model Ey::Core::Client::ServerUsage

  self.collection_root    = "server_usages"
  self.collection_request = :get_server_usages
end

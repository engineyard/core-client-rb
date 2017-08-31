class Ey::Core::Client::Networks < Ey::Core::Collection

  model Ey::Core::Client::Network

  self.model_root         = "network"
  self.model_request      = :get_network
  self.collection_root    = "networks"
  self.collection_request = :get_networks
end

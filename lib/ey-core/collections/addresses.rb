class Ey::Core::Client::Addresses < Ey::Core::Collection

  model Ey::Core::Client::Address

  self.model_root         = "address"
  self.model_request      = :get_address
  self.collection_root    = "addresses"
  self.collection_request = :get_addresses
end

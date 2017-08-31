class Ey::Core::Client::Subnets < Ey::Core::Collection

  model Ey::Core::Client::Subnet

  self.model_root         = "subnet"
  self.model_request      = :get_subnet
  self.collection_root    = "subnets"
  self.collection_request = :get_subnets
end

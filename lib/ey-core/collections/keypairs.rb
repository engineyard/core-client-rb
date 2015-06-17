class Ey::Core::Client::Keypairs < Ey::Core::Collection

  model Ey::Core::Client::Keypair

  self.model_root         = "keypair"
  self.model_request      = :get_keypair
  self.collection_root    = "keypairs"
  self.collection_request = :get_keypairs
end

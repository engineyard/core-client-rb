class Ey::Core::Client::KeypairDeployments < Ey::Core::Collection

  model Ey::Core::Client::KeypairDeployment

  self.model_root         = "keypair_deployment"
  self.model_request      = :get_keypair_deployment
  self.collection_root    = "keypair_deployments"
  self.collection_request = :get_keypair_deployments
end

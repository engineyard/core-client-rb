class Ey::Core::Client::Deployments < Ey::Core::Collection
  model Ey::Core::Client::Deployment

  self.model_root         = "deployment"
  self.model_request      = "get_deployment"
  self.collection_root    = "deployments"
  self.collection_request = "get_deployments"
end

class Ey::Core::Client::ApplicationDeployments < Ey::Core::Collection

  model Ey::Core::Client::ApplicationDeployment

  self.model_root         = "application_deployment"
  self.model_request      = :get_application_deployment
  self.collection_root    = "application_deployments"
  self.collection_request = :get_application_deployments
end

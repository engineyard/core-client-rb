class Ey::Core::Client::ContainerServiceDeployments < Ey::Core::Collection

  model Ey::Core::Client::ContainerServiceDeployment

  self.model_root         = "container_service_deployment"
  self.model_request      = :get_container_service_deployment
  self.collection_root    = "container_service_deployments"
  self.collection_request = :get_container_service_deployments

  def discover(task_definition_arn)
    params = {
      "task_definition_arn" => task_definition_arn
    }

    connection.requests.new(connection.discover_container_service_deployments(params).body["request"])
  end
end

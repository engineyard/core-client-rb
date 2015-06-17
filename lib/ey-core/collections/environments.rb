class Ey::Core::Client::Environments < Ey::Core::Collection

  model Ey::Core::Client::Environment

  self.model_root         = "environment"
  self.model_request      = :get_environment
  self.collection_root    = "environments"
  self.collection_request = :get_environments

  def alerting(params={})
    connection.environments.load(
      self.connection.get_alerting_environments(params)
    )
  end
end

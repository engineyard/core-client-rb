class Ey::Core::Client::EnvironmentVariables < Ey::Core::Collection
  model Ey::Core::Client::EnvironmentVariable

  self.model_root         = "environment_variable"
  self.model_request      = :get_environment_variable
  self.collection_root    = "environment_variables"
  self.collection_request = :get_environment_variables
end

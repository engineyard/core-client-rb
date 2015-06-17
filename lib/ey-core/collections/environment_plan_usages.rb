class Ey::Core::Client::EnvironmentPlanUsages < Ey::Core::Collection

  model Ey::Core::Client::EnvironmentPlanUsage

  self.collection_root    = "environment_plan_usages"
  self.collection_request = :get_environment_plan_usages
end

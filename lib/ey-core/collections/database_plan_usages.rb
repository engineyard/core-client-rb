class Ey::Core::Client::DatabasePlanUsages < Ey::Core::Collection

  model Ey::Core::Client::DatabasePlanUsage

  self.collection_root    = "database_plan_usages"
  self.collection_request = :get_database_plan_usages
end

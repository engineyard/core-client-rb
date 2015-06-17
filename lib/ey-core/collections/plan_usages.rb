class Ey::Core::Client::PlanUsages < Ey::Core::Collection

  model Ey::Core::Client::PlanUsage

  self.collection_root    = "plan_usages"
  self.collection_request = :get_plan_usages
end

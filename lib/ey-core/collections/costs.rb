class Ey::Core::Client::Costs < Ey::Core::Collection
  model Ey::Core::Client::Cost

  self.model_root         = "cost"
  self.model_request      = :get_cost
  self.collection_root    = "costs"
  self.collection_request = :get_costs
end

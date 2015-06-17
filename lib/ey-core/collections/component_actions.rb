class Ey::Core::Client::ComponentActions < Ey::Core::Collection

  model Ey::Core::Client::ComponentAction

  self.model_root         = "component_action"
  self.model_request      = :get_component_action
  self.collection_root    = "component_actions"
  self.collection_request = :get_component_actions
end

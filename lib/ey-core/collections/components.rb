class Ey::Core::Client::Components < Ey::Core::Collection

  model Ey::Core::Client::Component

  self.model_root         = "component"
  self.model_request      = :get_component
  self.collection_root    = "components"
  self.collection_request = :get_components
end

class Ey::Core::Client::SlotComponents < Ey::Core::Collection

  model Ey::Core::Client::SlotComponent

  self.model_root         = "slot_component"
  self.model_request      = :get_slot_component
  self.collection_root    = "slot_components"
  self.collection_request = :get_slot_components
end

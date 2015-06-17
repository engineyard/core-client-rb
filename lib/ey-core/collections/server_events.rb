class Ey::Core::Client::ServerEvents < Ey::Core::Collection

  model Ey::Core::Client::ServerEvent

  self.model_root         = "server_event"
  self.model_request      = :get_server_event
  self.collection_root    = "server_events"
  self.collection_request = :get_server_events
end

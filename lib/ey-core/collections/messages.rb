class Ey::Core::Client::Messages < Ey::Core::Collection

  model Ey::Core::Client::Message

  self.collection_request = :get_messages
  self.collection_root    = "messages"
  self.model_request      = :get_message
  self.model_root         = "message"
end

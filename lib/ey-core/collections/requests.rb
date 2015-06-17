class Ey::Core::Client::Requests < Ey::Core::Collection

  model Ey::Core::Client::Request

  self.model_root = "request"
  self.model_request = :get_request

  self.collection_root = "requests"
  self.collection_request = :get_requests
end

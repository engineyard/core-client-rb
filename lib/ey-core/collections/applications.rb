class Ey::Core::Client::Applications < Ey::Core::Collection

  model Ey::Core::Client::Application

  self.model_root         = "application"
  self.model_request      = :get_application
  self.collection_root    = "applications"
  self.collection_request = :get_applications
end

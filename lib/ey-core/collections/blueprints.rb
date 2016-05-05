class Ey::Core::Client::Blueprints < Ey::Core::Collection

  model Ey::Core::Client::Blueprint

  self.model_root         = "blueprint"
  self.model_request      = :get_blueprint
  self.collection_root    = "blueprints"
  self.collection_request = :get_blueprints
end

class Ey::Core::Client::Features < Ey::Core::Collection

  model Ey::Core::Client::Feature

  self.model_root         = "feature"
  self.model_request      = :get_feature
  self.collection_root    = "features"
  self.collection_request = :get_features
end

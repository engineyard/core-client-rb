class Ey::Core::Client::Gems < Ey::Core::Collection
  model Ey::Core::Client::Gem

  self.model_request = :get_gem
  self.model_root = "gem"
end

class Ey::Core::Client::ComputeFlavors < Ey::Core::Collection

  model Ey::Core::Client::ComputeFlavor

  self.model_root         = "flavor"
  self.model_request      = :get_compute_flavor
  self.collection_root    = "flavors"
  self.collection_request = :get_compute_flavors

end

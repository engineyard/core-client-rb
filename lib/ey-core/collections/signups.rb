class Ey::Core::Client::Signups < Ey::Core::Collection
  model Ey::Core::Client::Signup

  self.model_root         = "signup"
  self.model_request      = :get_signup
  self.collection_root    = "signups"
  self.collection_request = :get_signups
end


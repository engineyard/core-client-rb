class Ey::Core::Client::Memberships < Ey::Core::Collection

  model Ey::Core::Client::Membership

  self.model_root         = "membership"
  self.model_request      = :get_membership
  self.collection_root    = "memberships"
  self.collection_request = :get_memberships
end

class Ey::Core::Client::Firewalls < Ey::Core::Collection

  model Ey::Core::Client::Firewall

  self.model_root         = "firewall"
  self.model_request      = :get_firewall
  self.collection_root    = "firewalls"
  self.collection_request = :get_firewalls
end

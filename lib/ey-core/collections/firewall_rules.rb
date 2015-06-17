class Ey::Core::Client::FirewallRules < Ey::Core::Collection

  model Ey::Core::Client::FirewallRule

  self.model_root         = "firewall_rule"
  self.model_request      = :get_firewall_rule
  self.collection_root    = "firewall_rules"
  self.collection_request = :get_firewall_rules
end

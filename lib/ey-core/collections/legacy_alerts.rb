class Ey::Core::Client::LegacyAlerts < Ey::Core::Collection

  model Ey::Core::Client::LegacyAlert

  self.model_root         = "legacy_alert"
  self.model_request      = :get_legacy_alert
  self.collection_root    = "legacy_alerts"
  self.collection_request = :get_legacy_alerts
end

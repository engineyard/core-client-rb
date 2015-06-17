class Ey::Core::Client::Alerts < Ey::Core::Collection

  model Ey::Core::Client::Alert

  self.model_root         = "alert"
  self.model_request      = :get_alert
  self.collection_root    = "alerts"
  self.collection_request = :get_alerts
end

class Ey::Core::Client::AutoScalingAlarms < Ey::Core::Collection
  model Ey::Core::Client::AutoScalingAlarm

  self.model_root         = "auto_scaling_alarm"
  self.model_request      = :get_auto_scaling_alarm
  self.collection_root    = "auto_scaling_alarms"
  self.collection_request = :get_auto_scaling_alarms
end

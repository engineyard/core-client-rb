class Ey::Core::Client::Logs < Ey::Core::Collection

  model Ey::Core::Client::Log

  self.model_root         = "log"
  self.model_request      = :get_log
  self.collection_root    = "logs"
  self.collection_request = :get_logs
end

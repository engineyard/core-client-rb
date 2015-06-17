class Ey::Core::Client::Backups < Ey::Core::Collection

  model Ey::Core::Client::Backup

  self.model_root         = "backup"
  self.model_request      = :get_backup
  self.collection_root    = "backups"
  self.collection_request = :get_backups
end

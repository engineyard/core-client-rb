class Ey::Core::Client::BackupFiles < Ey::Core::Collection

  model Ey::Core::Client::BackupFile

  self.model_root         = "backup_file"
  self.model_request      = :get_backup_file
  self.collection_root    = "backup_files"
  self.collection_request = :get_backup_files
end

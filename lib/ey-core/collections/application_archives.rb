class Ey::Core::Client::ApplicationArchives < Ey::Core::Collection

  model Ey::Core::Client::ApplicationArchive

  self.model_root         = "application_archive"
  self.model_request      = :get_application_archive
  self.collection_root    = "application_archives"
  self.collection_request = :get_application_archives
end

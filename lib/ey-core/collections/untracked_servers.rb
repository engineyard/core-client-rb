class Ey::Core::Client::UntrackedServers < Ey::Core::Collection

  model Ey::Core::Client::UntrackedServer

  self.model_root         = "untracked_server"
  self.model_request      = :get_untracked_server
  self.collection_root    = "untracked_servers"
  self.collection_request = :get_untracked_servers
end

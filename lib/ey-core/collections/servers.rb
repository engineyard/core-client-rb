class Ey::Core::Client::Servers < Ey::Core::Collection

  model Ey::Core::Client::Server

  self.model_root         = "server"
  self.model_request      = :get_server
  self.collection_root    = "servers"
  self.collection_request = :get_servers
end

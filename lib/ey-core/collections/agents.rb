class Ey::Core::Client::Agents < Ey::Core::Collection

  model Ey::Core::Client::Agent

  self.model_root         = "agent"
  self.model_request      = :get_agent
  self.collection_root    = "agents"
  self.collection_request = :get_agents
end

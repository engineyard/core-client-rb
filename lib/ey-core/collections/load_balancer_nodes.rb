class Ey::Core::Client::LoadBalancerNodes < Ey::Core::Collection

  model Ey::Core::Client::LoadBalancerNode

  self.model_root         = "load_balancer_node"
  self.model_request      = :get_load_balancer_node
  self.collection_root    = "load_balancer_nodes"
  self.collection_request = :get_load_balancer_nodes
end

class Ey::Core::Client::LoadBalancerServices < Ey::Core::Collection

  model Ey::Core::Client::LoadBalancerService

  self.model_root         = "load_balancer_service"
  self.model_request      = :get_load_balancer_service
  self.collection_root    = "load_balancer_services"
  self.collection_request = :get_load_balancer_services
end

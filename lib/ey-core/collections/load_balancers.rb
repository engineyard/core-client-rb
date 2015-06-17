class Ey::Core::Client::LoadBalancers < Ey::Core::Collection

  model Ey::Core::Client::LoadBalancer

  self.model_root         = "load_balancer"
  self.model_request      = :get_load_balancer
  self.collection_root    = "load_balancers"
  self.collection_request = :get_load_balancers

  def create(params={})
    create!(params)
    self
  rescue Ey::Core::Response::Error
    false
  end
end

class Ey::Core::Client::LoadBalancerNode < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :deleted_at, type: :time

  attribute :provisioner_id

  has_one :load_balancer_service, aliases: "service"
  has_one :server

  def service
    load_balancer_service
  end
end

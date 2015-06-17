class Ey::Core::Client::LoadBalancerService < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :deleted_at, type: :time
  attribute :provisioner_id
  attribute :internal_port
  attribute :external_port
  attribute :internal_protocol
  attribute :external_protocol

  has_one :load_balancer, aliases: "nodes"
  has_one :provider_ssl_certificate

  has_many :load_balancer_nodes

  def nodes
    load_balancer_nodes
  end
end

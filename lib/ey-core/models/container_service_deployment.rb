class Ey::Core::Client::ContainerServiceDeployment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :container_service_id
  attribute :public_ip_address
  attribute :private_ip_address
  attribute :port_mappings
  attribute :health_status
  attribute :container_health_status
  attribute :container_instance_id
  attribute :task_arn
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :deleted_at, type: :time
end

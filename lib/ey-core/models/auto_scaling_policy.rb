class Ey::Core::Client::AutoScalingPolicy < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :provisioned_id
  attribute :provisioner_id
  attribute :type
  attribute :name
  attribute :configuration
  attribute :auto_scaling_group_id

  has_one :auto_scaling_group

  def save!
    if new_record?
      requires :provisioned_id, :provisioner_id, :name, :configuration, :auto_scaling_group_id

      params = {
        "url"                => self.collection.url,
        "auto_scaling_group" => {
          "name" => self.name,
          "configuration" => self.configuration,
          "provisioned_id" => self.provisioned_id,
          "provisioner_id" => self.provisioner_id,
          "auto_scaling_group_id" => self.auto_scaling_group_id
        }
      }

      connection.requests.new(connection.create_auto_scaling_group(params).body["request"])
    else
      requires :identity

      params = {
        "id" => self.identity,
        "auto_scaling_group" => {
          "name" => self.name,
          "configuration" => self.configuration,
          "provisioned_id" => self.provisioned_id,
          "provisioner_id" => self.provisioner_id,
          "auto_scaling_group_id" => self.auto_scaling_group_id
        }
      }

      connection.requests.new(connection.update_auto_scaling_policy(params).body["request"])
    end
  end
end

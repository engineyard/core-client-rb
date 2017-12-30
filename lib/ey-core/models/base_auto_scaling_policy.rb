class Ey::Core::Client::BaseAutoScalingPolicy < Ey::Core::Model
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
    requires :auto_scaling_group_id
    params = {
      "url"                 => self.collection.url,
      "auto_scaling_policy" => {
        "name" => self.name
      }.merge(policy_params),
      "auto_scaling_group_id"  => self.auto_scaling_group_id
    }

    if new_record?
      policy_requires
      requires :name
      connection.requests.new(connection.create_auto_scaling_policy(params).body["request"])
    else
      requires :identity
      params.merge("id" => identity)
      connection.requests.new(connection.update_auto_scaling_policy(params).body["request"])
    end
  end

  def destroy!
    connection.requests.new(
      self.connection.destroy_auto_scaling_policy("id" => self.id).body["request"]
    )
  end

  def alarm
    requires :identity

    data = self.connection.get_auto_scaling_alarms(
      "auto_scaling_policy_id" => identity
    ).body["auto_scaling_alarms"]

    self.connection.auto_scaling_alarms.load(data).first
  end

  private

  def policy_params
    raise NotImplementedError
  end

  def policy_requires
    raise NotImplementedError
  end
end

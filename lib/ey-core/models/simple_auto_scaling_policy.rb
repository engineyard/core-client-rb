class Ey::Core::Client::SimpleAutoScalingPolicy < Ey::Core::Client::BaseAutoScalingPolicy
  identity :id
  attribute :auto_scaling_group_id, aliases: "auto_scaling_group", squash: ["id"]
  attribute :cooldown, type: :integer
  attribute :action_unit
  attribute :action_type
  attribute :action_value

  has_many :auto_scaling_alarms

  def policy_params
    {
      "cooldown"     => cooldown,
      "action_unit"  => action_unit,
      "action_type"  => action_type,
      "action_value" => action_value,
      "type"         => type
    }
  end

  def policy_requires
    requires :action_value, :action_type, :action_unit
  end
end

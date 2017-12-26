class Ey::Core::Client::AutoScalingPolicy < Ey::Core::Client::SimpleAutoScalingPolicy
  identity :id
  attribute :auto_scaling_group_id, aliases: "auto_scaling_group", squash: ["id"]
  attribute :cooldown, type: :integer
  attribute :action_unit
  attribute :action_type
  attribute :action_value

  def policy_params
    requires :action_value
  end

  def policy_requires
    {
      "cooldown"     => cooldown,
      "action_unit"  => action_unit,
      "action_type"  => action_type,
      "action_value" => action_value,
      "type"         => type
    }
  end
end

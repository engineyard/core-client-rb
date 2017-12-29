class Ey::Core::Client::StepAutoScalingPolicy < Ey::Core::Client::BaseAutoScalingPolicy
  identity :id
  attribute :auto_scaling_group_id, aliases: "auto_scaling_group", squash: ["id"]
  attribute :estimated_warmup, type: :integer
  attribute :action_type
  attribute :action_unit
  attribute :steps, type: :array

  def policy_params
    {
      "estimated_warmup" => estimated_warmup,
      "action_type"      => action_type,
      "action_unit"      => action_unit,
      "steps"            => steps,
      "type"             => type
    }
  end

  def policy_requires
    requires :steps
  end
end

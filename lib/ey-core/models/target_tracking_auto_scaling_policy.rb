class Ey::Core::Client::TargetTrackingAutoScalingPolicy < Ey::Core::Client::BaseAutoScalingPolicy
  identity :id
  attribute :auto_scaling_group_id, aliases: "auto_scaling_group", squash: ["id"]
  attribute :estimated_warmup, type: :integer
  attribute :target_value,     type: :float
  attribute :disable_scale_in, type: :boolean
  attribute :metric_type

  has_many :auto_scaling_alarms

  def policy_params
    {
      "estimated_warmup" => estimated_warmup,
      "target_value"     => target_value,
      "disable_scale_in" => disable_scale_in,
      "metric_type"      => metric_type,
      "type"             => type
    }
  end

  def policy_requires
    requires :target_value
  end
end

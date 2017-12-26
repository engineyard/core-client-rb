class Ey::Core::Client::AutoScalingPolicies < Ey::Core::Collection
  model Ey::Core::Client::AutoScalingPolicy


  MODELS_TO_TYPE = {
    "simple" => Ey::Core::Client::SimpleAutoScalingPolicy,
    # "step"   => Ey::Core::Client::StepAutoScalingPolicy,
    # "target" => Ey::Core::Client::TargetTrackingAutoScalingPolicy
  }.freeze


  self.model_root         = "auto_scaling_policy"
  self.model_request      = :get_auto_scaling_policy
  self.collection_root    = "auto_scaling_policies"
  self.collection_request = :get_auto_scaling_policies

  def new(attributes = {})
    unless attributes.is_a?(::Hash)
      raise(ArgumentError.new("Initialization parameters must be an attributes hash, got #{attributes.class} #{attributes.inspect}"))
    end
    type = attributes[:type].presence || "simple"
    model = MODELS_TO_TYPE[type]
    unless model
      raise(ArgumentError.new("Unrecognized policy type #{type}. Allowed types are: #{MODELS_TO_TYPE.keys.join(', ')}"))
    end
    model.new(
      {
        :collection => self,
        :connection => connection,
      }.merge(attributes)
    )
  end
end

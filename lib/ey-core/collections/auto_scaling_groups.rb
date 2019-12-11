class Ey::Core::Client::AutoScalingGroups < Ey::Core::Collection
  model Ey::Core::Client::AutoScalingGroup

  self.model_root         = "auto_scaling_group"
  self.model_request      = :get_auto_scaling_group
  self.collection_root    = "auto_scaling_groups"
  self.collection_request = :get_auto_scaling_groups
end

module Ey
  module Core
    module TestHelpers
      module AutoScalingHelpers
        def create_auto_scaling_group(options = {})
          environment = options[:environment] || create_environment

          groups = client.auto_scaling_groups

          groups.create!(
            minimum_size: 2,
            maximum_size: 6,
            environment: environment
          ).resource!
        end

        def create_auto_scaling_policy(options = {})
          group = options.delete(:auto_scaling_group) || create_auto_scaling_group
          policies = client.auto_scaling_policies

          policies.create!(
            {
              auto_scaling_group_id: group.id,
              action_value: 2,
              action_unit: "instances",
              action_type: "add",
              name: SecureRandom.hex(16),
              type: "simple"
            }.merge(options)
          ).resource!
        end
      end
    end
  end
end

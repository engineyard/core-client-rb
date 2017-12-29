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
      end
    end
  end
end

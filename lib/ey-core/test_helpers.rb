require 'ey-core/test_helpers/account_helpers'
require 'ey-core/test_helpers/alert_helpers'
require 'ey-core/test_helpers/client_helpers'
require 'ey-core/test_helpers/resource_helpers'
require 'ey-core/test_helpers/auto_scaling_helpers'

module Ey
  module Core
    module TestHelpers
      include AccountHelpers
      include AlertHelpers
      include ClientHelpers
      include ResourceHelpers
      include AutoScalingHelpers
    end
  end
end

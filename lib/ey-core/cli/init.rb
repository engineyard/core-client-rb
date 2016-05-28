require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/deprecated'

module Ey
  module Core
    module Cli
      class Init < Subcommand
        include Helpers::Deprecated

        deprecate('init')
      end
    end
  end
end

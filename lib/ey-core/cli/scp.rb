require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/deprecated'

module Ey
  module Core
    module Cli
      class Scp < Subcommand
        include Helpers::Deprecated

        deprecate('scp')
      end
    end
  end
end

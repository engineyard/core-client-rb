require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Version < Subcommand
        title "version"
        summary "Print the version of the gem"

        def handle
          puts Ey::Core::VERSION
        end
      end
    end
  end
end

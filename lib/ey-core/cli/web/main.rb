require 'ey-core/cli/subcommand'
require 'ey-core/cli/web/disable'
require 'ey-core/cli/web/enable'
require 'ey-core/cli/web/restart'

module Ey
  module Core
    module Cli
      module Web
        class Main < Ey::Core::Cli::Subcommand
          title "web"
          summary "Web related commands"

          mount Disable
          mount Enable
          mount Restart
        end
      end
    end
  end
end

require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class CurrentUser < Subcommand
        title "current_user"
        summary "Print the current user information"

        def handle
          ap core_client.users.current
        end
      end
    end
  end
end

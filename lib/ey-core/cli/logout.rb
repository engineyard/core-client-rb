require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Logout < Subcommand
        title "logout"
        summary "Remove your Engine Yard API token"

        def handle
          if core_yaml[core_url]
            core_yaml.delete(core_url)
            write_core_yaml
            puts "Successfully removed API token from credentials file".green
          else
            puts "No API token found".yellow
          end
        end
      end
    end
  end
end

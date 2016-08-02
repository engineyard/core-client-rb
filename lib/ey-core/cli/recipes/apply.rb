require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/chef'

module Ey
  module Core
    module Cli
      module Recipes
        class Apply < Subcommand
          include Helpers::Chef

          title "apply"
          summary "Apply changes to an environment"

          option :account,
            short: "c",
            long: "account",
            description: "Name or id of account",
            argument: "account"

          option :environment,
            short: "e",
            long: "environment",
            description: "Name or id of environment",
            argument: "environment"

          switch :quick,
            short: "q",
            long: "quick",
            description: "Quick chef run (if not specified, will run main chef run)"

          switch :verbose,
            long: "verbose",
            description: "verbose chef run (include chef setup and stack traces)"

          switch :no_wait,
            long: "no-wait",
            description: "Don't wait for apply to finish, exit after started"

          option :watch,
            long: "watch",
            description: "Specify an instance amazon_id or server role to watch chef logs (defaults to app_master)",
            argument: "instance"

          def handle
            operator, environment = core_operator_and_environment_for(options)
            raise "Unable to find matching environment" unless environment

            opts = {}
            opts[:no_wait] = switch_active?(:no_wait)
            opts[:verbose] = switch_active?(:verbose)
            opts[:watch]   = option(:watch)
            run_chef(run_type, environment, opts)
          end

          private

          def run_type
            (switch_active?(:quick) && "quick") || "main"
          end

        end
      end
    end
  end
end

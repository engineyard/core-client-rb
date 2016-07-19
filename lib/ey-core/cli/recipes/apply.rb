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

          def handle
            operator, environment = core_operator_and_environment_for(options)
            raise "Unable to find matching environment" unless environment

            run_chef(run_type, environment)
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

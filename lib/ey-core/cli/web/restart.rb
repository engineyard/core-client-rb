require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      module Web
        class Restart < Ey::Core::Cli::Subcommand
          title "restart"
          summary "Restart all application servers in an environment"

          option :environment,
            short: "e",
            long: "environment",
            description: "Name or id of the environment to deploy to.",
            argument: "environment"

          option :account,
            short: "c",
            long: "account",
            description: "Name or id of the account that the environment resides in.",
            argument: "account"

          def handle
            operator, environment = core_operator_and_environment_for(options)

            puts "Restarting application servers in #{environment.name}".green

            request = environment.restart_app_servers
            request.wait_for { |r| r.ready? }

            if request.successful
              puts "Successfully restarted application servers".green
            else
              puts "Restarting application servers has failed".red
              ap request
            end
          end
        end
      end
    end
  end
end

require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      module Web
        class Enable < Ey::Core::Cli::Subcommand
          title "enable"
          summary "Remove the maintenance page for this application in the given environment."

          option :app,
            short: "a",
            long: "app",
            description: "Name or id of the application whose maintenance page will be removed",
            argument: "app"

          option :environment,
            short: "e",
            long: "environment",
            description: "Name or id of the environment to deploy to.",
            argument: "Environment"

          option :account,
            short: 'c',
            long: 'account',
            description: 'Name or ID of the account that the environment resides in.',
            argument: 'account'

          def handle
            operator, environment = core_operator_and_environment_for(self.options)
            application           = core_application_for(environment, options)
            puts "Disabling maintenance for #{application.name} on #{environment.name}".green
            request = environment.maintenance(application, "disable")
            request.wait_for { |r| r.ready? }
            if request.successful
              puts "Successfully disabled maintenance page".green
            else
              puts "Disabling maintenance mode was not successful".red
              ap request
            end
          end
        end
      end
    end
  end
end

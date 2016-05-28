require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Status < Subcommand
        title "status"
        summary "Show the deployment status of the app"
        description <<-DESC
Show the current status of the most recent deployment of the specifed application and environment
DESC

        option :environment,
          short: "e",
          long: "environment",
          description: "Name or id of the environment to deploy to.",
          argument: "Environment"

        option :account,
          short: 'c',
          long: 'account',
          description: 'Name or ID of the account that the environment resides in.  If no account is specified, the app will deploy to the first environment that meets the criteria, in the accounts you have access to.',
          argument: 'Account name or id'

        option :app,
          short: "a",
          long: "app",
          description: "Application name or ID to deploy.  If :account is not specified, this will be the first app that matches the criteria in the accounts you have access to.",
          argument: "app"

        def handle
          operator, environment = core_operator_and_environment_for(self.options)
          deployments = core_client.
            deployments.
            all(environment_id: environment.id, application_id: app.id)

          ap deployments.first
        end

        private
        def app
          core_application_for(options)
        end
      end
    end
  end
end

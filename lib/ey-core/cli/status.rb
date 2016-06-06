require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Status < Subcommand
        title "status"
        summary "Show the deployment status of the app"
        description <<-DESC
Given an environment name and an application name, show the status of the most recent deployment of that application on the environment in question.

Optionally, one may also specify the account to use in the case that one has several accounts with identical environment/application names.

If an account is specified, the deployment in question will come from the environment and application within that account. Otherwise, we use the first account available that matches for both the environment and the application.
DESC

        option :account,
          short: 'a',
          long: 'account',
          description: 'Name or ID of the account to query',
          argument: 'Account name or id'

        arg :environment
        arg :app

        def handle
          deployment = deployments.first

          ap deployment ? deployment : no_deployments_found
        end

        private
        def app_name
          arg(:app).first
        end

        def app
          api.applications.first(name: app_name)
        end

        def environment_name
          arg(:environment).first
        end

        def environment
          @environment ||= api.environments.first(name: environment_name)
        end

        def api
          @api ||= self.operator(options)
        end

        def deployments
          @deployments ||= api.
            deployments.
            all(environment: environment.id, application: app.id)
        end

        def no_deployments_found
          "We couldn't find a deployment matching the criteria you provided."
        end
      end
    end
  end
end

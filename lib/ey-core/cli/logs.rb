require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Logs < Subcommand
        title "logs"
        summary "Retrieve the latest logs for an environment"
        description <<-DESC
Displays Engine Yard configuration logs for all servers in the environment.  If
recipes were uploaded to the environment & run, their logs will also be
displayed beneath the main configuration logs.
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

        option :server,
          short: 's',
          long: 'server',
          description: "Only retrieve logs for the specified server",
          argument: "id or amazon_id"

        def handle
          operator, environment = core_operator_and_environment_for(options)
          abort "Unable to find matching environment".red unless environment

          servers = if option(:server)
                      [environment.servers.get(option(:server))] || environment.servers.all(provisioned_id: option(:server))
                    else
                      environment.servers.all
                    end

          abort "No servers found".red if servers.empty?

          servers.each do |server|
            name = server.name ? "#{server.name} (#{server.role})" : server.role

            if log = server.latest_main_log
              puts "Main logs for #{name}:".green
              puts log.contents
            end

            if log = server.latest_custom_log
              puts "Custom logs for #{name}:".green
              puts log.contents
            end
          end
        end
      end
    end
  end
end

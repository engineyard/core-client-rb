require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Servers < Subcommand
        title "servers"
        summary "List servers you have access to"

        option :account,
          short: 'c',
          long: 'account',
          description: 'Filter by account name or id',
          argument: 'Account'

        option :environment,
          short: "-e",
          long: "environment",
          description: "Filter by environment.",
          argument: "environment"

        def handle
          abort_on_ambiguous_environment

          puts servers.empty? ?
            "No servers were found that match your criteria." :
            TablePrint::Printer.
            new(servers, [{id: {width: 10}}, :role, :provisioned_id]).
            table_print
        end

        private
        def environment_name
          option(:environment)
        end

        def abort_on_ambiguous_environment
          if environment_name
            abort "The criteria you've provided matches multiple environments. Please refine further with an account." if possible_environments.length > 1
          end
        end

        def possible_environments
          return @possible_environments if @possible_environments

          @possible_environments = [core_client.environments.get(environment_name)].compact

          @possible_environments = core_client.environments.all(name: environment_name).to_a if @possible_environments.empty?

          @possible_environments
        end

        def applicable_environment
          core_client.environments.get(option(:environment)) ||
            core_client.environments.first(name: option(:environment))
        end

        def servers
          @servers ||= AccountFilter.filter(
            EnvironmentFilter.filter(
              core_client.servers.all,
              applicable_environment
            ),
            core_account
          )
        end

        module AccountFilter
          def self.filter(servers, account)
            return servers unless account

            servers.select {|server| server.account == account}
          end
        end

        module EnvironmentFilter
          def self.filter(servers, environment)
            return servers unless environment

            servers.select {|server| server.environment == environment}
          end
        end
      end
    end
  end
end

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

          @possible_environments = all_pages(core_client.environments.all, name: environment_name).to_a if @possible_environments.empty?

          @possible_environments
        end

        def applicable_environment
          possible_environments.first
        end

        def servers
          @servers ||= all_pages(core_client.servers, server_filters)
        end

        def server_filters
          filters = {}
          filters[:account] = core_account if option(:account)
          filters[:environment] = applicable_environment if environment_name
          filters
        end
      end
    end
  end
end

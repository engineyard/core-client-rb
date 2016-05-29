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
          puts TablePrint::Printer.
            new(servers, [{id: {width: 10}}, :role, :provisioned_id]).
            table_print
        end

        private
        def servers
          if option(:account)
            core_client.servers.all(account: core_account)
          elsif environment = option(:environment)
            (core_client.environments.get(environment) || core_client.environments.first(name: environment)).servers.all
          else
            core_client.servers.all
          end
        end
      end
    end
  end
end

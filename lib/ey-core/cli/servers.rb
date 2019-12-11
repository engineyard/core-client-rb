require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Servers < Subcommand
        title 'servers'
        summary 'List servers you have access to'

        option :account,
          short: 'c',
          long: 'account',
          description: 'Filter by account name or id',
          argument: 'account'

        option :environment,
          short: 'e',
          long: 'environment',
          description: 'Filter by environment.',
          argument: 'environment'

        option :role,
          short: 'r',
          long: 'role',
          description: 'Filter by server role.',
          argument: 'role'

        def handle
          puts TablePrint::Printer.new(
            servers,
            [
              { id: { width: 10 } },
              :role,
              :provisioned_id,
              { public_hostname: { width: 50 } },
              :name,
            ]
          ).table_print
        end

        private
        def servers
          filter_opts = {}

          operator =
            if option(:environment)
              core_account.environments.first(name: option(:environment))
            else
              filter_opts[:account] = core_account.id if option(:account)
              core_client
            end

          filter_opts[:role] = option(:role).split(',') if option(:role)
          operator ? operator.servers.all(filter_opts) : nil
        end
      end
    end
  end
end

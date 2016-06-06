require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Environments < Subcommand
        title "environments"
        summary "Retrieve a list of Engine Yard environments that you have access to."

        option :account,
          short: 'a',
          long: 'account',
          description: 'Filter by account name or id',
          argument: 'Account'

        def handle
          table_data = TablePrint::Printer.new(
            environments,
            [{id: {width: 10}}, :name]
          )

          puts table_data.table_print
        end

        private
        def environments
          if option(:account)
            core_account.environments.all
          else
            current_accounts.map(&:environments).flatten.sort_by(&:id)
          end
        end
      end
    end
  end
end

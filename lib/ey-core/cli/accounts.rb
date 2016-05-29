require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Accounts < Subcommand
        title "accounts"
        summary "Retrieve a list of Engine Yard accounts that you have access to."

        def handle
          puts "current user in app == '#{core_client.users.current.attributes}'"
          puts "current user accounts: '#{core_client.users.current.accounts.all.length}'"
          puts "user count == #{core_client.users.all.length}"
          puts "client data == '#{core_client.data}'"
          table_data = TablePrint::Printer.new(current_accounts, [{id: {width: 36}}, :name])
          puts table_data.table_print
        end
      end
    end
  end
end

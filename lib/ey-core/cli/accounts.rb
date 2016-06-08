require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Accounts < Subcommand
        title "accounts"
        summary "Retrieve a list of Engine Yard accounts that you have access to."

        def handle
          table_data = TablePrint::Printer.new(core_accounts, [{id: {width: 36}}, :name])
          puts table_data.table_print
        end
      end
    end
  end
end

class Ey::Core::Cli::Accounts < Ey::Core::Cli::Subcommand
  title "accounts"
  summary "Retrieve a list of Engine Yard accounts that you have access to."

  def handle
    table_data = TablePrint::Printer.new(current_accounts, [{id: {width: 36}}, :name])
    puts table_data.table_print
  end
end

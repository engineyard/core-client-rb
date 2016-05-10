class Ey::Core::Cli::Applications < Ey::Core::Cli::Subcommand
  title "applications"
  summary "Retrieve a list of Engine Yard applications that you have access to."
  option :account, short: 'c', long: 'account', description: 'Filter by account name or id', argument: 'Account'

  def handle
    applications = if option(:account)
                     core_account_for(options).applications.all
                   else
                     current_accounts.map(&:applications).flatten.sort_by(&:id)
                   end

    table_data = TablePrint::Printer.new(applications, [{id: {width: 10}}, :name])
    puts table_data.table_print
  end
end

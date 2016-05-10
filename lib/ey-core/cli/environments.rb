class Ey::Core::Cli::Environments < Ey::Core::Cli::Subcommand
  title "environments"
  summary "Retrieve a list of Engine Yard environments that you have access to."
  option :account, short: 'c', long: 'account', description: 'Filter by account name or id', argument: 'Account'

  def handle
    environments = if option(:account)
                     core_account_for(options).environments.all
                   else
                     current_accounts.map(&:environments).flatten.sort_by(&:id)
                   end


    table_data = TablePrint::Printer.new(environments, [{id: {width: 10}}, :name])
    puts table_data.table_print
  end
end

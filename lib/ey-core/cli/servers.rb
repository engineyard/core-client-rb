class Ey::Core::Cli::Servers < Ey::Core::Cli::Subcommand
  title "servers"
  summary "List servers you have access to"
  option :account, short: 'c', long: 'account', description: 'Filter by account name or id', argument: 'Account'
  option :environment, short: "-e", long: "environment", description: "Filter by environment.", argument: "environment"

  def handle
    servers = if option(:account)
                account = core_account_for(options)
                core_client.servers.all(account: account)
              elsif environment = option(:environment)
                (core_client.environments.get(environment) || core_client.environments.first(name: environment)).servers.all
              else
                core_client.servers.all
              end

    puts TablePrint::Printer.new(servers, [{id: {width: 10}}, :role, :provisioned_id]).table_print
  end
end

require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/stream_printer'

module Ey
  module Core
    module Cli
      class Environments < Subcommand
        include Ey::Core::Cli::Helpers::StreamPrinter
        title "environments"
        summary "Retrieve a list of Engine Yard environments that you have access to."

        option :account,
          short: 'c',
          long: 'account',
          description: 'Filter by account name or id',
          argument: 'Account'

        def handle
          if option(:account)
            stream_print("ID" => 10, "Name" => 50) do |printer|
              core_account.environments.each_entry do |env|
                printer.print(env.id, env.name)
              end
            end
          else
            stream_print("ID" => 10, "Name" => 50, "Account" => 50) do |printer|
              core_accounts.each_entry do |account|
                account.environments.each_entry do |env|
                  printer.print(env.id, env.name, account.name)
                end
              end
            end
          end
        end

      end
    end
  end
end

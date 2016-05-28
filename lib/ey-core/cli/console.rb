require 'ey-core/cli/subcommand'
require 'pry'

module Ey
  module Core
    module Cli
      class Console < Subcommand
        title "console"
        summary "Start an interactive console"

        option :execute_command,
          short: "e",
          long: "command",
          description: "Command to execute",
          argument: "command"

        def handle
          if command = option(:execute_command)
            core_client.instance_eval(command)
          else
            Pry.config.prompt = proc { |obj, nest_level, _| "ey-core:> " }
            core_client.pry
          end
        end
      end
    end
  end
end

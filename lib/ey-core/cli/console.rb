class Ey::Core::Cli::Console < Ey::Core::Cli::Subcommand
  title "console"
  summary "Start an interactive console"
  option :execute_command, short: "c", long: "command", description: "Command to execute", argument: "command"

  def handle
    if command = option(:execute_command)
      core_client.instance_eval(command)
    else
      Pry.config.prompt = proc { |obj, nest_level, _| "ey-core:> " }
      core_client.pry
    end
  end
end

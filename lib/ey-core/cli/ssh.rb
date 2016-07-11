require 'ey-core/cli/helpers/server_sieve'
require 'ey-core/cli/subcommand'

module Ey
  module Core
    module Cli
      class Ssh < Subcommand
        title "ssh"
        summary "Open an SSH session to the environment's application master"

        option :account,
          short: "c",
          long: "account",
          description: "Name or id of account",
          argument: "account"

        option :environment,
          short: "e",
          long: "environment",
          description: "Name or id of environment",
          argument: "environment"

        option :server,
          short: 's',
          long: "server",
          description: "Specific server to ssh into. Id or amazon id (i-12345)",
          argument: "server"

        option :utilities,
          long: "utilities",
          description: "Run command on the utility servers with the given names. Specify all to run the command on all utility servers.",
          argument: "'all,resque,redis,etc'"

        option :command,
          long: "command",
          description: "Command to run",
          argument: "'command with args'"

        option :shell,
          long: "shell",
          description: "Run command in a shell other than bash",
          argument: "shell"

        option :bind_address,
          long: "bind_address",
          description: "When no command is specified, pass -L to ssh",
          argument: "bind address"

        switch :all,
          long: "all",
          description: "Run command on all servers"

        switch :app_servers,
          long: "app_servers",
          description: "Run command on all application servers"

        switch :db_servers,
          long: "db_servers",
          description: "Run command on all database servers"

        switch :db_master,
          long: "db_master",
          description: "Run command on database master"

        switch :db_slaves,
          long: "db_slaves",
          description: "Run command on database slaves"

        switch :tty,
          short: 't',
          long: "tty",
          description: "Allocated a tty for the command"

        def handle
          operator, environment = core_operator_and_environment_for(options)
          abort "Unable to find matching environment".red unless environment

          cmd      = option(:command)
          ssh_opts = []
          ssh_cmd  = ["ssh"]
          exits    = []
          user     = environment.username
          servers  = []

          if option(:command)
            if shell = option(:shell)
              cmd = Escape.shell_command([shell,'-lc',cmd])
            end

            if switch_active?(:tty)
              ssh_opts << "-t"
            elsif cmd.match(/sudo/)
              puts "sudo commands often need a tty to run correctly. Use -t option to spawn a tty.".yellow
            end

            servers += Ey::Core::Cli::Helpers::ServerSieve.filter(
              environment.servers,
              all: switch_active?(:all),
              app_servers: switch_active?(:app_servers),
              db_servers: switch_active?(:db_servers),
              db_master: switch_active?(:db_master),
              utilities: option(:utilities)
            )
          else
            if option(:bind_address)
              ssh_opts += ["-L", option(:bind_address)]
            end

            if option(:server)
              servers += [core_server_for(server: option[:server], operator: environment)]
            else
              servers += Ey::Core::Cli::Helpers::ServerSieve.filter(
                environment.servers,
                all: switch_active?(:all),
                app_servers: switch_active?(:app_servers),
                db_servers: switch_active?(:db_servers),
                db_master: switch_active?(:db_master),
                utilities: option(:utilities)
              )
            end
          end

          if servers.empty?
            abort "Unable to find any matching servers. Aborting.".red
          end

          servers.uniq!

          servers.each do |server|
            host = server.public_hostname
            name = server.name ? "#{server.role} (#{server.name})" : server.role
            puts "\nConnecting to #{name} #{host}".green
            sshcmd = Escape.shell_command((ssh_cmd + ["#{user}@#{host}"] + [cmd]).compact)
            puts "Running command: #{sshcmd}".green
            system sshcmd
            exits << $?.exitstatus
          end

          exit exits.detect {|status| status != 0 } || 0
        end
      end
    end
  end
end

require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/log_streaming'

module Ey
  module Core
    module Cli
      class Deploy < Subcommand
        include Ey::Core::Cli::Helpers::LogStreaming
        title "deploy"
        summary "Deploy your application"

        option :environment,
          short: "e",
          long: "environment",
          description: "Name or id of the environment to deploy to.",
          argument: "Environment"

        option :account,
          short: 'c',
          long: 'account',
          description: 'Name or ID of the account that the environment resides in.  If no account is specified, the app will deploy to the first environment that meets the criteria, in the accounts you have access to.',
          argument: 'Account name or id'

        option :ref,
          short: "r",
          long: "ref",
          description: "A git reference to deploy.",
          argument: "ref"

        option :migrate,
          short: "m",
          long: "migrate",
          description: "The migration command to run.  This option has a 50 character limit.",
          argument: "migrate"

        option :app,
          short: "a",
          long: "app",
          description: "Application name or ID to deploy.  If :account is not specified, this will be the first app that matches the criteria in the accounts you have access to.",
          argument: "app"

        switch :no_wait,
          long: "no-wait",
          description: "Don't wait for deploy to finish, exit after deploy is started"

        switch :verbose,
          short: "v",
          long: "verbose",
          description: "Deploy with verbose output"

        switch :verbose,
          short: "v",
          long: "verbose",
          description: "Stream deploy output to this console. Alias to stream for backwards compatibility."

        switch :no_migrate,
          long: "no-migrate",
          description: "Skip migration."

        def handle
          operator, environment = core_operator_and_environment_for(self.options)
          if operator.is_a?(Ey::Core::Client::Account)
            abort <<-EOF
Found account #{operator.name} but requested account #{option(:account)}.
Use the ID of the account instead of the name.
This can be retrieved by running "ey accounts".
EOF
            .red unless operator.name == option(:account) || operator.id == option(:account)
          end

          unless environment
            abort "Unable to locate environment #{option[:environment]} in #{operator.name}".red
          end

          unless option(:account)
            self.options.merge!(environment: environment)
          end

          app = core_application_for(environment, self.options)

          deploy_options = {verbose: options[:verbose], cli_args: ARGV}
          latest_deploy = nil
          if options[:ref]
            deploy_options.merge!(ref: option(:ref))
          else
            puts "--ref not provided, checking latest deploy...".yellow
            latest_deploy ||= environment.latest_deploy(app)
            if latest_deploy && latest_deploy.ref
              deploy_options[:ref] = latest_deploy.ref
            else
              raise "--ref is required (HEAD is the typical choice)"
            end
          end
          if (option(:migrate) || switch_active?(:no_migrate))
            deploy_options.merge!(migrate_command: option(:migrate)) if option(:migrate)
            deploy_options.merge!(migrate_command: nil) if switch_active?(:no_migrate)
          else
            puts "missing migrate option (--migrate or --no-migrate), checking latest deploy...".yellow
            latest_deploy ||= environment.latest_deploy(app)
            if latest_deploy
              deploy_options.merge!(migrate_command: (latest_deploy.migrate && latest_deploy.migrate_command) || nil)
            else
              raise "either --migrate or --no-migrate needs to be specified"
            end
          end
          request = environment.deploy(app, deploy_options)

          puts <<-EOF
Deploy started to environment: #{environment.name} with application: #{app.name}
Request ID: #{request.id}
EOF
          ap request
          ap request.resource
          if switch_active?(:no_wait)
            puts("Deploy started".green + " (use status command with --tail to view output)")
          else
            stream_deploy_log(request)
          end
        end
      end
    end
  end
end

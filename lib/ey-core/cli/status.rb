require 'ey-core/cli/helpers/log_streaming'

class Ey::Core::Cli::Status < Ey::Core::Cli::Subcommand
  include Ey::Core::Cli::Helpers::LogStreaming
  title "status"
  summary "Show the deployment status of the app"

  option :environment, short: "e", long: "environment", description: "Name or id of the environment to deploy to.", argument: "Environment"
  option :account,     short: 'c', long: 'account',     description: 'Name or ID of the account that the environment resides in.  If no account is specified, the app will deploy to the first environment that meets the criteria, in the accounts you have access to.', argument: 'Account name or id'
  option :app,         short: "a", long: "app",         description: "Application name or ID to deploy.  If :account is not specified, this will be the first app that matches the criteria in the accounts you have access to.", argument: "app"

  switch :tail, long: "tail",     description: "tail in-progress deployment log"

  description <<-DESC
    Show the current status of the most recent deployment of the specifed application and environment
  DESC

  def handle
    operator, environment = core_operator_and_environment_for(self.options)
    app                   = core_application_for(environment, self.options)
    deploy                = environment.latest_deploy(app)

    puts environment.release_label
    puts "#{environment.servers.size} servers"
    environment.servers.each do |s|
      puts [s.provisioned_id, s.role, s.state].join(" ")
    end
    if deploy
      ap deploy
      ap deploy.request
      if switch_active?(:tail)
        stream_deploy_log(deploy.request)
      end
    else
      puts "Never Deployed"
    end
  end
end

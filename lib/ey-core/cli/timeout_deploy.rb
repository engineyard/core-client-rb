class Ey::Core::Cli::TimeoutDeploy < Ey::Core::Cli::Subcommand
  title "timeout-deploy"
  summary "Fail a stuck unfinished deployment"
  description <<-DESC
    NOTICE: Timing out a deploy does not stop currently running deploy
    processes.

    The latest running deployment will be marked as failed, allowing a
    new deployment to be run. It is possible to mark a potentially successful
    deployment as failed. Only run this when a deployment is known to be
    wrongly unfinished/stuck and when further deployments are blocked.
  DESC

  option :environment, short: "e", long: "environment", description: "Name or id of the environment to deploy to.", argument: "Environment"
  option :account,     short: 'c', long: 'account',     description: 'Name or ID of the account that the environment resides in.  If no account is specified, the app will deploy to the first environment that meets the criteria, in the accounts you have access to.', argument: 'Account name or id'
  option :app,         short: "a", long: "app",         description: "Application name or ID to deploy.  If :account is not specified, this will be the first app that matches the criteria in the accounts you have access to.", argument: "app"
  option :message,     short: "m", long: "message",     description: "Custom message for why the deploy is timed out", argument: "message"

  def handle
    operator, environment = core_operator_and_environment_for(self.options)
    app                   = core_application_for(self.options)
    deployment            = core_client.deployments.first(environment_id: environment.id, application_id: app.id)

    puts "Timing out the most recent deployment (deploy started at: #{deployment.started_at})".green
    deployment.timeout(option(:message))
    ap deployment
  end
end

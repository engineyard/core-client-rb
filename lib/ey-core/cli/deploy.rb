class Ey::Core::Cli::Deploy < Ey::Core::Cli::Subcommand
  title "deploy"
  summary "Deploy your application"

  option :environment, short: "e", long: "environment", description: "Name or id of the environment to deploy to.", argument: "Environment"
  option :account,     short: 'c', long: 'account',     description: 'Name or ID of the account that the environment resides in.  If no account is specified, the app will deploy to the first environment that meets the criteria, in the accounts you have access to.', argument: 'Account name or id'
  option :ref,         short: "r", long: "ref",         description: "A git reference to deploy.", argument: "ref"
  option :migrate,     short: "m", long: "migrate",     description: "The migration command to run.  This option has a 50 character limit.", argument: "migrate"
  option :app,         short: "a", long: "app",         description: "Application name or ID to deploy.  If :account is not specified, this will be the first app that matches the criteria in the accounts you have access to.", argument: "app"

  switch :stream, long: "stream",     description: "Stream deploy output to this console."
  switch :verbose, short: "v", long: "verbose",    description: "Stream deploy output to this console. Alias to stream for backwards compatibility."
  switch :no_migrate, long: "no-migrate", description: "Skip migration."

  def handle
    %w(environment app).each { |option| raise "--#{option} is required" unless options[option.to_sym] }
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

    app = core_application_for(self.options)

    deploy_options = {}
    deploy_options.merge!(ref: option(:ref)) if option(:ref)
    deploy_options.merge!(migrate_command: option(:migrate)) if option(:migrate)
    deploy_options.merge!(migrate_command: '') if switch_active?(:no_migrate)
    request = environment.deploy(app, deploy_options)

    puts <<-EOF
Deploy started to environment: #{environment.name} with application: #{app.name}
Request ID: #{request.id}
    EOF
    if switch_active?(:stream) || switch_active?(:verbose)
      request.subscribe { |m| print m["message"] if m.is_a?(Hash) }
      puts "" # fix console output from stream
    else
      request.wait_for { |r| r.ready? } # dont raise from ready!
    end

    if request.successful
      puts "Deploy successful!".green
    else
      abort <<-EOF
Deploy failed!
Request output:
#{request.message}
      EOF
      .red
    end
  end
end

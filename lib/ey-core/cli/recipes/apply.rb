class Ey::Core::Cli::Recipes::Apply < Ey::Core::Cli::Recipes
  title "apply"
  summary "Apply changes to an environment"
  option :account, short: "c", long: "account", description: "Name or id of account", argument: "account"
  option :environment, short: "e", long: "environment", description: "Name or id of environment", argument: "environment"

  switch :main, short: "m", long: "main", description: "Apply main recipes only"
  switch :custom, long: "custom", description: "Apply custom recipes only"
  switch :quick, short: "q", long: "quick", description: "Quick chef run"
  switch :full, short: "f", long: "full", description: "Run main and custom chef"

  def handle
    operator, environment = core_operator_and_environment_for(options)
    raise "Unable to find matching environment" unless environment

    run_type = if switch_active?(:main)
                 "main"
               elsif switch_active?(:custom)
                 "custom"
               elsif switch_active?(:quick)
                 "quick"
               elsif switch_active?(:full)
                 "main"
               else
                 "main"
               end

    run_chef(run_type, environment)

    if switch_active?(:full)
      run_chef("custom", environment)
    end
  end
end

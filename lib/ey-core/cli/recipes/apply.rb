class Ey::Core::Cli::Recipes::Apply < Ey::Core::Cli::Recipes
  title "apply"
  summary "Apply changes to an environment"
  option :account, short: "c", long: "account", description: "Name or id of account", argument: "account"
  option :environment, short: "e", long: "environment", description: "Name or id of environment", argument: "environment"

  switch :main, short: "m", long: "main", description: "Apply main recipes only"
  switch :custom, short: "u", long: "custom", description: "Apply custom recipes only"
  switch :quick, short: "q", long: "quick", description: "Quick chef run"
  switch :full, short: "f", long: "full", description: "Run main and custom chef"

  def handle
    validate_run_type_flags

    operator, environment = core_operator_and_environment_for(options)
    raise "Unable to find matching environment" unless environment

    run_chef(run_type, environment)

    if switch_active?(:full)
      run_chef("custom", environment)
    end
  end

  private
  def validate_run_type_flags
    if active_run_type_flags.length > 1
      kernel.abort(
        'Only one of --main, --custom, --quick, and --full may be specified.'
      )
    end
  end

  def run_type
    secondary_run_types[active_run_type] || default_run_type
  end

  def active_run_type
    active_run_type_flags.first
  end

  def active_run_type_flags
    [:main, :custom, :quick, :full].select {|switch| switch_active?(switch)}
  end

  def secondary_run_types
    {
      custom: 'custom',
      quick: 'quick'
    }
  end

  def default_run_type
    'main'
  end
end

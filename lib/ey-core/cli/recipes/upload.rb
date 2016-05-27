class Ey::Core::Cli::Recipes::Upload < Ey::Core::Cli::Recipes
  title "upload"
  summary "Upload custom recipes to an environment"
  option :environment, short: "e", long: "environment", description: "Environment that will receive the recipes.", argument: "environment"
  option :account,     short: "c", long: "account",     description: "Name of the account in which the environment can be found.", argument: "account"
  option :file,        short: "f", long: "file",        description: "Path to recipes", argument: "path"

  switch :apply, short: "a", long: "apply", description: "Apply the recipes immediately after they are uploaded"

  def handle
    operator, environment = core_operator_and_environment_for(options)
    path = option(:file) || "cookbooks/"

    puts "Uploading custom recipes for #{environment.name}".green
    begin
      upload_recipes(environment, path)
      puts "Uploading custom recipes complete".green
    rescue => e
      abort "There was a problem uploading the recipes".red
    end

    if switch_active?(:apply)
      run_chef("custom", environment)
    end
  end
end

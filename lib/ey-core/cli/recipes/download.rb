class Ey::Core::Cli::Recipes::Download < Ey::Core::Cli::Recipes
  title "download"
  summary "Download a copy of the custom chef recipes from this environment into the current directory"
  description <<-DESC
    The recipes will be unpacked into a directory called "cookbooks" in the
    current directory. This is the opposite of 'recipes upload'.

    If the cookbooks directory already exists, an error will be raised.
  DESC

  option :environment, short: "e", long: "environment", description: "Environment that will receive the recipes.", argument: "environment"
  option :account,     short: "c", long: "account",     description: "Name of the account in which the environment can be found.", argument: "account"

  def handle
    if File.exist?("cookbooks")
      raise Ey::Core::Clie::RecipesExist.new("Cannot download recipes, cookbooks directory already exists.")
    end

    operator, environment = core_operator_and_environment_for(options)
    puts "Downloading recipes".green
    recipes     = environment.download_recipes

    puts "Extracting recipes to 'cookbooks/'".green
    untar(ungzip(recipes), './')
  end
end

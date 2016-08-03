require 'ey-core/cli/subcommand'
require 'ey-core/cli/recipes/apply'
require 'ey-core/cli/recipes/download'
require 'ey-core/cli/recipes/upload'
require 'ey-core/cli/recipes/generate'

module Ey
  module Core
    module Cli
      module Recipes
        class Main < Ey::Core::Cli::Subcommand
          title "recipes"
          summary "Chef specific commands"

          mount Ey::Core::Cli::Recipes::Apply
          mount Ey::Core::Cli::Recipes::Download
          mount Ey::Core::Cli::Recipes::Upload
          mount Ey::Core::Cli::Recipes::Generate
        end
      end
    end
  end
end

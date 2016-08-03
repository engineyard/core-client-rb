require 'ey-core/cli/subcommand'
require 'ey-core/cli/helpers/chef'

module Ey
  module Core
    module Cli
      module Recipes
        class Generate < Subcommand
          include Helpers::Chef

          title "generate"
          summary "Generate a skeleton custom chef cookbook"

          option :path,
            long: "path",
            description: "Path to recipes",
            argument: "path"

          option :name,
            long: "name",
            description: "name of custom recipe",
            argument: "name"

          def handle
            path = File.expand_path(option(:path) || "cookbooks")
            name = option(:name) || abort("Please name (--name) your cookbooks".red)
            puts "Creating cookbooks named #{name} in #{path}"
            file("#{path}/ey-custom/README.md",
              default: "TODO")
            file("#{path}/ey-custom//metadata.rb",
              default: "#TODO",
              append: "depends 'ey-custom/#{name}'")
            file("#{path}/ey-custom/recipes/after-main.rb",
              default: "#TODO",
              append: "include_recipe \"ey-custom/::my_recipe\"")
          end

        end
      end
    end
  end
end

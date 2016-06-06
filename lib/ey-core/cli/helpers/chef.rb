require 'ey-core/cli/errors'

module Ey
  module Core
    module Cli
      module Helpers
        module Chef
          def run_chef(type, environment)
            request = environment.apply(type)

            puts "#{run_msg(type)} #{env_msg(environment)}"

            request.wait_for { |r| r.ready? }
            if request.successful
              puts "#{type.capitalize} chef run completed".green
            else
              puts "#{type.capitalize} chef run failed".red
              ap request
            end
          end

          def run_msg(type)
            "Started #{type} chef run".green
          end

          def env_msg(environment)
            "(account: #{environment.account.name}, environment: #{environment.name})".yellow
          end

          def upload_recipes(environment, path="cookbooks/")
            recipes_path = Pathname.new(path)

            if recipes_path.exist? && recipes_path.to_s.match(/\.(tgz|tar\.gz)/)
              environment.upload_recipes(recipes_path)
            elsif recipes_path.exist?
              environment.upload_recipes(archive_directory(path))
            else
              raise RecipesNotFound, "Recipes file not found: #{recipes_path}"
            end
          end
        end
      end
    end
  end
end

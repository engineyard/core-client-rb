require 'ey-core/cli/errors'

module Ey
  module Core
    module Cli
      module Helpers
        module Chef
          def run_chef(type, environment, options = {})
            no_wait = options.delete(:no_wait)
            options[:streaming] = true unless no_wait
            request = environment.apply(type, options)
            puts "Started #{type} chef run".green
            if no_wait
              return
            end
            streamable_instance_update = nil
            if request.read_channel
              request.subscribe do |m|
                print m["message"] if m.is_a?(Hash)
              end
              puts "" # fix console output from stream
            else
              request.wait_for { |r| r.ready? }
            end
            if request.successful
              puts "#{type.capitalize} chef run completed".green
            else
              puts "#{type.capitalize} chef run failed".red
              ap request
              if server = environment.servers.first
                puts "For logs try `ey logs --server #{server.provisioned_id}` --environment #{environment.name}"
              end
            end
          end

          def upload_recipes(environment, path="cookbooks/")
            recipes_path = Pathname.new(path)

            if recipes_path.exist? && recipes_path.to_s.match(/\.(tgz|tar\.gz)/)
              environment.upload_recipes(recipes_path)
            elsif recipes_path.exist?
              environment.upload_recipes(archive_directory(path))
            else
              raise RecipesNotFound, "Recipes not found, expected to find chef recipes in: #{File.expand_path(recipes_path)}, use --file to specify a different path"
            end
          end
        end
      end
    end
  end
end

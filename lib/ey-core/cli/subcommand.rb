require 'belafonte'
require 'colorize'
require 'table_print'
require 'ey-core'
require 'ey-core/cli/helpers/core'

module Ey
  module Core
    module Cli
      class Subcommand < Belafonte::App
        include Ey::Core::Cli::Helpers::Core

        def setup
          $stdout = stdout
          $stderr = stderr
          $stdin = stdin
          $kernel = kernel
        end

        def run_handle
          super
        rescue Ey::Core::Response::Error => e
          if ENV["DEBUG"]
            puts e.inspect
            puts e.backtrace
          end
          handle_core_error(e)
        rescue => e
          if ENV["DEBUG"]
            puts e.inspect
            puts e.backtrace
          end
          stderr.puts "Error:".red
          stderr.puts Wrapomatic.wrap(e.message, indents: 1)
          raise SystemExit.new(255)
        end

        #TODO: a lot more errors that would could handle with nice messages, eventually this should probably be it's own class
        def handle_core_error(e)
          stderr.puts "Error: #{e.error_type}".red
          Array(e.response.body["errors"] || [e.message]).each do |message|
            stderr.puts Wrapomatic.wrap(message, indents: 1)
          end
          if e.is_a?(Ey::Core::Response::Unauthorized)
            stderr.puts "Check the contents of ~/.ey-core vs https://cloud.engineyard.com/cli"
          end
          raise SystemExit.new(255)
        end

      end
    end
  end
end

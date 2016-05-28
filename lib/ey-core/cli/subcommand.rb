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
      end
    end
  end
end

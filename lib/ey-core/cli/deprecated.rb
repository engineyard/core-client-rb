require 'belafonte'
require 'colorize'

module Ey
  module Core
    module Cli
      class Deprecated < Belafonte::App
        summary 'This command has been deprecated'
        description <<-DESC
This command has been deprecated. We aplogize for any inconvenience.
DESC

        def handle
          abort "This command is deprecated".red
        end
      end
    end
  end
end

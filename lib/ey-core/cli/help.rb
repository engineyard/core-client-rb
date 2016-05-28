require 'belafonte'

module Ey
  module Core
    module Cli
      class Help < Belafonte::App
        title 'help'
        summary 'Print out the help docs'

        arg :command_line,
          times: :unlimited

        def handle
          Main.new(
            command_line.unshift('-h'),
            stdin,
            stdout,
            stderr,
            kernel
          ).execute!
        end

        private
        def command_line
          arg(:command_line)
        end
      end
    end
  end
end

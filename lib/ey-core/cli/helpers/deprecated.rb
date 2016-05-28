require 'colorize'

module Ey
  module Core
    module Cli
      module Helpers
        module Deprecated
        # Class-level helpers pulled into an including class
          module ClassMethods

            # A helper for deprecating a Belafonte-based command
            #
            # @param deprecated_title [String] the title of the command
            #
            # @return [NilClass] this method is not expected to return a value
            def deprecate(deprecated_title)
              title deprecated_title
              summary 'This command has been deprecated'
              description <<-DESCRIPTION
The #{meta[:title]} command has been deprecated. We apologize for any inconvenience.
DESCRIPTION
            end
          end

          # Module magic
          # @api private
          def self.included(base)
            base.extend(ClassMethods)
          end

          # Terminate the deprecated command with a message
          def handle
            abort "This command is deprecated".red
          end
        end
      end
    end
  end
end

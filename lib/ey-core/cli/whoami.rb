require 'ey-core/cli/current_user'

module Ey
  module Core
    module Cli
      class Whoami < CurrentUser
        title "whoami"
        summary "Print the current user information (alias for current_user)"
      end
    end
  end
end

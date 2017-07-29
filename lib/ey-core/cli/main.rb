#require 'optparse'
#require 'ostruct'
#require 'ey-core'
require 'ey-core/cli'
require 'awesome_print'
require 'belafonte'
require 'rubygems/package'
require 'escape'
require 'highline/import'

require 'ey-core/cli/accounts'
require 'ey-core/cli/applications'
require 'ey-core/cli/console'
require 'ey-core/cli/current_user'
require 'ey-core/cli/deploy'
require 'ey-core/cli/environments'
require 'ey-core/cli/environment_variables'
require 'ey-core/cli/help'
require 'ey-core/cli/init'
require 'ey-core/cli/login'
require 'ey-core/cli/logout'
require 'ey-core/cli/logs'
require 'ey-core/cli/recipes'
require 'ey-core/cli/scp'
require 'ey-core/cli/servers'
require 'ey-core/cli/ssh'
require 'ey-core/cli/status'
require 'ey-core/cli/timeout_deploy'
require 'ey-core/cli/version'
require 'ey-core/cli/web'
require 'ey-core/cli/whoami'

Cistern.formatter = Cistern::Formatter::AwesomePrint


module Ey
  module Core
    module Cli
      class Main < Belafonte::App
        title "Engineyard CLI"
        summary "Successor to the engineyard gem"

        mount Accounts
        mount Applications
        mount Console
        mount CurrentUser
        mount Deploy
        mount Environments
        mount EnvironmentVariables
        mount Help
        mount Init
        mount Login
        mount Logout
        mount Logs
        mount Recipes::Main
        mount Scp
        mount Servers
        mount Ssh
        mount Status
        mount TimeoutDeploy
        mount Version
        mount Web::Main
        mount Whoami
      end
    end
  end
end

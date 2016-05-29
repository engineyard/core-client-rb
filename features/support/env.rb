require 'simplecov'
SimpleCov.coverage_dir 'feature-coverage'
SimpleCov.minimum_coverage 95
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/mock/'
  add_group 'Libraries', 'lib'
  add_group 'CLI', 'lib/ey-core/cli'
  add_group 'CLI Helpers', 'lib/ey-core/cli/helpers'
end

require 'aruba/cucumber'
require 'factis/cucumber'
require 'ey-core'
require 'ey-core/version'
require 'ey-core/cli/main'

EXE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '/../../exe'))
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Aruba.configure do |config|
  config.command_search_paths = config.command_search_paths << EXE_DIR
  config.home_directory = File.join(config.root_directory, config.working_directory)
  config.command_launcher = :in_process
  config.main_class = Ey::Core::Cli::Main
end

Before do
  # Using "announce" causes massive warnings on 1.9.2
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
  ENV['CORE_URL'] ||= "http://api-development.localdev.engineyard.com:9292"
end

After do
  ENV['RUBYLIB'] = @original_rubylib
  ENV.delete('CORE_URL')
end

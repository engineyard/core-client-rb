# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ey-core/version'

Gem::Specification.new do |gem|
  gem.name          = "ey-core"
  gem.version       = Ey::Core::VERSION
  gem.authors       = ["Engine Yard Engineering"]
  gem.email         = ["engineering@engineyard.com"]
  gem.description   = %q{Engine Yard Core API Ruby Client}
  gem.summary       = %q{Client library providing real and mock functionality for accessing Engine Yard's Core API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.licenses      = ["MIT"]

  gem.required_ruby_version = ">= 2.5"

  gem.add_dependency "addressable"

  gem.add_dependency "amazing_print", "~> 1.1.0"
  gem.add_dependency "belafonte"
  gem.add_dependency "cistern", "~> 0.12.3"
  gem.add_dependency "colorize"
  gem.add_dependency "ey-hmac", "~> 2.0"
  gem.add_dependency "escape"
  gem.add_dependency "hashie", "~> 4.1.0"
  gem.add_dependency "faraday", "~> 1.0.1"
  gem.add_dependency "faraday_middleware", "~> 1.0.0"
  gem.add_dependency "rack"
  gem.add_dependency "faye"
  gem.add_dependency "highline"
  gem.add_dependency "json", "~> 2.3.0"
  gem.add_dependency "mime-types"
  gem.add_dependency "oj"
  gem.add_dependency "oj_mimic_json"
  gem.add_dependency "pry"
  gem.add_dependency "sshkey",  "~> 1.6"
  gem.add_dependency "table_print"

  gem.add_development_dependency "pry-nav"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "ffaker"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "aruba", "~> 0.11"
  gem.add_development_dependency "cucumber", "~> 2.1"
  gem.add_development_dependency "factis", "~> 1.0"
end

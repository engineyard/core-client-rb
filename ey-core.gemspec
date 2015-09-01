# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ey-core/version'

Gem::Specification.new do |gem|
  gem.name          = "ey-core"
  gem.version       = Ey::Core::VERSION
  gem.authors       = ["Josh Lane"]
  gem.email         = ["jlane@engineyard.com", "engineering@engineyard.com"]
  gem.description   = %q{Engine Yard Core API Ruby Client}
  gem.summary       = %q{Client library providing real and mock functionality for accessing Engine Yard's Core API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.licenses      = ["MIT"]

  gem.add_dependency "addressable", "~> 2.2"
  gem.add_dependency "cistern", "~> 0.12"
  gem.add_dependency "ey-hmac", "~> 2.0"
  gem.add_dependency "sshkey",  "~> 1.6"
  gem.add_dependency "faraday", "~> 0.9"
  gem.add_dependency "faraday_middleware", "~> 0.9"
  gem.add_dependency "mime-types"
end

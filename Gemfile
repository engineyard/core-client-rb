source 'https://rubygems.org'

# Specify your gem's dependencies in ey-core.gemspec
gemspec

gem "rack", "<= 2.1.4"

# We build the cookiejar from sources because of the following reason.
# The rubygems.org repository contains the latest cookiejar of the version 0.3.3. 
# It is the latest published version. But the gem sources have several unpublished fixes.
# One of them is about the support of the 'samesite' cookie which is used when we work with AWS ALB.
gem 'cookiejar', git: 'https://github.com/wzissel/cookiejar', branch: 'master'

group :doc do
  gem 'yard'
  gem 'redcarpet'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.3'
  gem 'faker'
  gem 'rack-test'
  gem 'rspec', '~> 3.1'
  gem 'simplecov'
  gem 'timecop'
end

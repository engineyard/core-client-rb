#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'cucumber/rake/task'

namespace :spec do
  task :mocked do
    sh "env MOCK_CORE=true bundle exec rspec spec/"
  end
  task :unmocked do
    sh "env MOCK_CORE=false CORE_URL=http://api-development.localdev.engineyard.com:9292 bundle exec rspec spec/"
  end
end

task :spec => ["spec:mocked", "spec:unmocked"]

Cucumber::Rake::Task.new

task default: ["spec:mocked", :cucumber]

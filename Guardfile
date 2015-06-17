# A sample Guardfile
# More info at https://github.com/guard/guard#readme


guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'rspec', cmd: "bundle exec rspec", all_on_start: true, failed_mode: :focus do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch(%r{^spec/(support|shared).*\.rb$}) { "spec" }
end

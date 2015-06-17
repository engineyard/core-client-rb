if ENV['COVERAGE'] and Kernel.respond_to? :caller_locations
  require 'cistern/coverage'

  SimpleCov.at_exit do
    puts "Adding cistern coverage data"

    result = SimpleCov.result

    models = Ey::Core::Client.constants.map {|c| Ey::Core::Client.const_get c }.select {|c| c.is_a? Class}.select {|c| c.superclass == Ey::Core::Model }

    models.each do |m|
      coverage_details = []

      coverage_details += m.attributes.values.select {|opts| opts[:coverage_hits] } rescue []
      coverage_details += m.associations.values.select {|opts| opts[:coverage_hits] } rescue []

      coverage_details.each do |options|
        unless result_file = result.files.find {|f| f.filename == options[:coverage_file] }
          raise "Coverage failed, couldn't find file '#{file}' in the coverage report"
        end

        # Use the actual calls to the attribute reader as the coverage metric
        result_file.line(options[:coverage_line]).instance_variable_set(:@coverage, options[:coverage_hits])
      end
    end

    result.format!
  end

  CodeClimate::TestReporter.start
  SimpleCov.start do
    add_filter 'spec'

    add_group 'Collections', 'lib/ey-core/collections'
    add_group 'Models', 'lib/ey-core/models'
    add_group 'Requests', 'lib/ey-core/requests'
  end
elsif ENV['COVERAGE']
  warn <<-WARN
Coverage reporting skipped.
This ruby version lacks necessary method Kernel.caller_locations"
  WARN
end

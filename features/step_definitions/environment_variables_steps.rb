Given(/^I have the following environment variables:$/) do |variables|
  variables.hashes.each do |variable_hash|
    application = known_apps.find { |app| app.name == variable_hash['Application Name'] }
    environment = known_environments.find { |env| env.name == variable_hash['Environment Name'] }
    known_environment_variables.push(
      create_environment_variable(
        application: application,
        environment: environment,
        environment_variable: {
          name: variable_hash['Name'],
          value: variable_hash['Value'],
          sensitive: variable_hash['Sensitive']
        }
      )
    )
  end
end

Then(/^I see the name and value for all of my environments as well as name of associated environment and application$/) do
  known_environment_variables.each do |environment_variable|
    expect(output_text).to match(match_environment_variable_regexp(environment_variable))
  end
end

Then(/^I see the environment variables associated with `(\w+)` environment$/) do |environment_name|
  known_environment_variables.each do |environment_variable|
    next unless environment_variable.environment_name == environment_name
    expect(output_text).to match(match_environment_variable_regexp(environment_variable))
  end
end

Then(/^I do not see environment variables associated with any other environments different from `(\w+)`$/) do |environment_name|
  known_environment_variables.each do |environment_variable|
    next if environment_variable.environment_name == environment_name
    expect(output_text).not_to match(match_environment_variable_regexp(environment_variable))
  end
end

Then(/^I see the environment variables associated with `(\w+)` application$/) do |application_name|
  known_environment_variables.each do |environment_variable|
    next unless environment_variable.application_name == application_name
    expect(output_text).to match(match_environment_variable_regexp(environment_variable))
  end
end

Then(/^I do not see environment variables associated with any other applications different from `(\w+)`$/) do |application_name|
  known_environment_variables.each do |environment_variable|
    next if environment_variable.application_name == application_name
    expect(output_text).not_to match(match_environment_variable_regexp(environment_variable))
  end
end

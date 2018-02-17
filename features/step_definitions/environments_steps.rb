Given %(each of my applications has an environment) do
  known_accounts.each do |account|
    account.applications.each do |app|
      known_environments.push(
        create_environment(
          account: account,
          application: app,
          environment: {
            name: "#{app.name}_env"
          }
        )
      )
    end
  end
end

Given(/^I have the following environments:$/) do |environments|
  environments.hashes.each do |environment_hash|
    application = known_apps.find { |app| app.name == environment_hash['Application Name'] }
    known_environments.push(
      create_environment(
        account: application.account,
        application: application,
        environment: {
          name: environment_hash['Environment Name']
        }
      )
    )
  end
end

Then %(I see the name and ID for all of my environments) do
  known_environments.each do |environment|
    expect(output_text).to match(/#{Regexp.escape(environment.id.to_s)}\s+\|\s+#{Regexp.escape(environment.name)}/)
  end
end

Then %(I see the environments in the one account) do
  account_named('one').environments.all.each do |environment|
    expect(output_text).to match(/#{Regexp.escape(environment.id.to_s)}\s+\|\s+#{Regexp.escape(environment.name)}/)
  end
end

Then %(I do not see environments from other accounts) do
  two = account_named('two').environments.all.to_a
  three = account_named('three').environments.all.to_a

  (two + three).each do |environment|
    expect(output_text).not_to match(/#{Regexp.escape(environment.id.to_s)}\s+\|\s+#{Regexp.escape(environment.name)}/)
  end

end

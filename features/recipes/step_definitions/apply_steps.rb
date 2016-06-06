Given %r(^I have an account named (.+)$) do |account_name|
  known_accounts.push(
    create_account(
      client: client,
      owner: current_user,
      account: {
        name: account_name
      }
    )
  )
end

Given %r(^(.+) has an application called (.+)$) do |account_name, app_name|
  known_apps.push(
    create_application(
      account: account_named(account_name),
      name: app_name
    )
  )
end

Given %r(^(.+) has the following environments:$) do |account_name, environment_names|

  account = account_named(account_name)
  app = account.applications.first
  environment_names.hashes.each do |environment_hash|
    known_environments.push(
      create_environment(
        account: account,
        application: app,
        environment: {
          name: environment_hash['Environment']
        }
      )
    )
  end
end

Then %r(^(.+) recipes are applied to the coyote environment$) do |run_type|
  expect(output_text).to match(/.*Started #{Regexp.escape(run_type)} chef run.*environment: coyote\).*/)
end

Then %(no changes are made to the roadrunner environment) do
  expect(output_text).not_to match(/.*chef run.*environment: roadrunner\).*/)
end

Then %(a quick run is applied to the coyote environment) do
  step %{quick recipes are applied to the coyote environment}
end

Then %(I'm advised that only one run type flag may be used) do
  expect(output_text).to match("Only one of --main, --custom, --quick, and --full may be specified.")
end

Then %(no changes are made to any environment) do
  expect(output_text).not_to match(/Started .* chef run.*\(account: .*/)
end

Then %(I am advised that my criteria matched several environments) do
  expect(output_text).to match(%{The criteria you've provided matches multiple environments. Please refine further with an account.})
end

Then %(the main recipes are applied to the coyote environment for ACME Inc) do
  expect(output_text).to match(/Started main chef run.*\(account: ACME Inc, environment: coyote\)/)
end

Then %(no changes are made to any other environment) do
  runs = output_text.split("\n").select {|line| line =~ /Started .* chef run.*\(/}
  expect(runs.count).to eql(1)
end

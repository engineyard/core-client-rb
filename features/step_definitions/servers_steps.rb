Given %(each of my environments has a server) do
  # Each environment implicitly gets a solo server, so this is just setting
  # up our known_servers collection
  known_environments.each do |environment|
    environment.servers.all.each do |server|
      known_servers.push(server)
    end
  end
end

Then %(I see the name, role, and provisioned ID for all of my servers) do
  known_servers.each do |server|
    expect(output_text).to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
  end
end

Then %(I see the servers in the one account) do
  account_named('one').environments.all.each do |environment|
    client.servers.all.to_a.select {|s| s.environment == environment}.each do |server|
      expect(server).not_to be_nil
      expect(output_text).to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
      seen_servers.push(server)
    end
  end
end

Then %(I do not see servers from other accounts) do
  step %{I do not see any other servers}
end

Then %(I see the servers in the one_1_env environment) do
  environment_named('one_1_env').servers.all.to_a.each do |server| 
      expect(server).not_to be_nil
      expect(output_text).to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
      seen_servers.push(server)
  end
end

Then %(I do not see servers from other environments) do
  step %{I do not see any other servers}
end

Given %(the two account has an environment named one_1_env with a server) do
  account_named('two').tap do |account|
    account.applications.all.to_a.last.tap do |app|
      known_environments.push(
        create_environment(
          account: account,
          application: app,
          environment: {
            name: 'one_1_env'
          }
        )
      )
    end
  end

  known_servers.push(
    known_environments.last.servers.first
  )
end

Then %(I do not see any servers) do
  known_servers.each do |server|
    expect(output_text).not_to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
  end
end

Then %(I am advised that my filters yielded ambiguous results) do
  expect(output_text).to include("The criteria you've provided matches multiple environments. Please refine further with an account.")
end

Then %(I see the servers from the one_1_env environment in the one account) do
  account = account_named('one')
  environment = account.environments.first(name: 'one_1_env')

  environment.servers.all.to_a.each do |server|
    expect(server).not_to be_nil
    expect(output_text).to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
    seen_servers.push(server)
  end
end

Then %(I do not see any other servers) do
  (known_servers - seen_servers).each do |server|
    expect(output_text).not_to match(/#{Regexp.escape(server.id.to_s)}\s+\|\s+#{Regexp.escape(server.role)}\s+\|\s+#{Regexp.escape(server.provisioned_id)}/)
  end
end

Then %(I am advised that my filters matched no servers) do
  expect(output_text).
    to include('No servers were found that match your criteria.')
end

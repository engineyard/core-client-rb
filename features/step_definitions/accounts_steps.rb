Given %(I'm an Engine Yard user) do
  memorize_fact(:me, create_user(client: client))
  true
end

Given %(ey-core is configured with my cloud token) do
  add_config_option(
    ENV['CORE_URL'] => current_user_hash['token']
  )
end

Given %(I'm associated with several accounts) do
  account1 = create_account(client: client, owner: current_user)
  account2 = create_account(client: client, owner: current_user)
  memorize_fact(:accounts, [account1, account2])

  asdf = client.instance_eval {@current_user}
  puts "there are #{client.accounts.all.length} accounts"
  puts "accounts: #{client.accounts.all.map(&:id)}"
  puts "current user == '#{current_user.id}'"
  puts "current user hash == '#{current_user_hash}'"
end

Then %(I see the name and ID of each of my accounts) do
  puts "all output == '#{output_text}'"
  recall_fact(:accounts).each do |account|
    expect(output_text).to include(account.id)
    expect(output_text).to include(account.name)
  end
end

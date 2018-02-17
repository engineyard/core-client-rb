Given %(I'm an Engine Yard user) do
  memorize_fact(:me, create_user(client: client))
  true
end

Given %(ey-core is configured with my cloud token) do
  add_config_option(
    'https://api.engineyard.com/' => current_user_hash['token']
  )
end

Given %(I'm associated with several accounts) do
  account1 = create_account(client: client, owner: current_user)
  account2 = create_account(client: client, owner: current_user)
  memorize_fact(:accounts, [account1, account2])
end

Given %r(^I have the following accounts:$) do |account_names|
  account_names.hashes.each do |account_hash|
    known_accounts.push(
      create_account(
        client: client,
        owner: current_user,
        account: {
          name: account_hash['Account Name']
        }
      )
    )
  end
end

Then %(I see the name and ID of each of my accounts) do
  recall_fact(:accounts).each do |account|
    expect(output_text).to include(account.id)
    expect(output_text).to include(account.name)
  end
end

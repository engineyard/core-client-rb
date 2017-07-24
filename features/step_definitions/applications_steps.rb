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

Given %(each of my accounts has several applications) do
  known_accounts.each do |account|
    known_apps.push(
      create_application(account: account, name: "#{account.name}_1")
    )

    known_apps.push(
      create_application(account: account, name: "#{account.name}_2")
    )
  end
end

Then %(I see the name and ID for all of my applications) do
  known_apps.each do |app|
    expect(output_text).to match(/#{Regexp.escape(app.id.to_s)}\s+\|\s+#{Regexp.escape(app.name)}/)
  end
end

Then %(I see the applications in the one account) do
  account_named('one').applications.all.each do |app|
    expect(output_text).to match(/#{Regexp.escape(app.id.to_s)}\s+\|\s+#{Regexp.escape(app.name)}/)
  end
end

Then %(I do not see applications from other accounts) do
  two = account_named('two').applications.all.to_a
  three = account_named('three').applications.all.to_a

  (two + three).each do |app|
    expect(output_text).not_to match(/#{Regexp.escape(app.id.to_s)}\s+\|\s+#{Regexp.escape(app.name)}/)
  end
end

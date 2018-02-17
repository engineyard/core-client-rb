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

Given(/^I have the following applications:$/) do |applications|
  applications.hashes.each do |application_hash|
    account = known_accounts.find { |acc| acc.name == application_hash['Account Name'] }
    known_apps.push(create_application(account: account, name: application_hash['Application Name']))
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

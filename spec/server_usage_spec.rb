require "spec_helper"

describe "server_usage", :mock_only do
  let!(:client)      { create_client }
  let!(:account)     { create_account(client: client, account: { owner: create_user(client: client)}) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { create_environment(account: account, name: SecureRandom.hex(10)) }

  before(:each) do
    now             = Time.now
    billing_month   = now.strftime("%Y-%m")
    month_beginning = DateTime.new(now.year, now.month, 1)

    client.find(:server_usages, account.id).merge!(
      "2014-05" => [
        {
          "start_at"    => "2014-05-01T00:00:00+00:00",
          "end_at"      => "2014-05-31T23:59:59+00:00",
          "report_time" => Time.now.iso8601,
          "flavor"      => "m1.large",
          "dedicated"   => false,
          "location"    => "us-east-1d",
          "environment" => "https://api.engineyard.com/environments/#{environment.id}",
          "provider"    => "https://api.engineyard.com/providers/#{provider.id}",
        },
      ],
      billing_month => [
        {
          "start_at"    => month_beginning.iso8601,
          "end_at"      => nil, # still running
          "report_time" => now.iso8601,
          "flavor"      => "m1.large",
          "dedicated"   => false,
          "location"    => "correct-location",
          "environment" => "https://api.engineyard.com/environments/#{environment.id}",
          "provider"    => "https://api.engineyard.com/providers/#{provider.id}",
        },
      ],
    )
  end

  it "can fetch usage for an account and billing_month" do
    server_usages = client.server_usages.all(account_id: account.id, billing_month: "2014-05")

    expect(server_usages.size).to eq(1)

    server_usage = server_usages.first

    expect(server_usage.start_at).not_to be_nil
    expect(server_usage.end_at).not_to be_nil
    expect(server_usage.report_time).not_to be_nil

    expect(server_usage.flavor).to   eq("m1.large")
    expect(server_usage.location).to eq("us-east-1d")

    expect(server_usage.dedicated).to be false

    expect(server_usage.environment).to eq(environment)
    expect(server_usage.provider).to    eq(provider)
  end

  it "defaults to the current billing_month" do
    server_usages = client.server_usages.all(account_id: account.id)

    expect(server_usages.size).to eq(1)

    server_usage = server_usages.first
    expect(server_usage.location).to eq("correct-location")
  end
end

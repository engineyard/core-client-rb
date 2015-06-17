require "spec_helper"

describe "server_usage", :mock_only do
  let!(:client)      { create_client }
  let!(:account)     { create_account(client: client, account: { owner: create_user(client: client)}) }
  let!(:provider)    { create_provider(account: account) }
  let!(:database_service)    { create_database_service(provider: provider) }

  before(:each) do
    client.find(:database_server_usages, account.id).merge!(
      "2014-07" => [
        {
          "start_at"         => "2014-05-01T00:00:00+00:00",
          "end_at"           => "2014-05-31T23:59:59+00:00",
          "report_time"      => Time.now.iso8601,
          "provisioned_id"   => "e982somedb",
          "flavor"           => "db.r3.8xlarge",
          "multi_az"         => false,
          "master"           => false,
          "location"         => "us-east-1d",
          "database_service" => "https://api.engineyard.com/database_services/#{database_service.id}",
          "provider"         => "https://api.engineyard.com/providers/#{provider.id}",
        },
      ]
    )
  end

  it "can fetch usage for an account and billing_month" do
    database_server_usages = client.database_server_usages.all(account_id: account.id, billing_month: "2014-07")

    expect(database_server_usages.size).to eq(1)

    database_server_usage = database_server_usages.first

    expect(database_server_usage.start_at).not_to be_nil
    expect(database_server_usage.end_at).not_to be_nil
    expect(database_server_usage.report_time).not_to be_nil

    expect(database_server_usage.provisioned_id).to   eq("e982somedb")
    expect(database_server_usage.flavor).to   eq("db.r3.8xlarge")
    expect(database_server_usage.multi_az).to eq(false)
    expect(database_server_usage.master).to   eq(false)
    expect(database_server_usage.location).to eq("us-east-1d")

    expect(database_server_usage.database_service).to eq(database_service)
    expect(database_server_usage.provider).to    eq(provider)
  end

end

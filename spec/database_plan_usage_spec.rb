require "spec_helper"

describe "plan_usage", :mock_only do
  let!(:client)  { create_client }
  let!(:account) { create_account(client: client, account: { owner: create_user(client: client)}) }
  let!(:provider)    { create_provider(account: account) }
  let!(:database_service)    { create_database_service(provider: provider) }

  before(:each) do
    client.find(:database_plan_usages, account.id).merge!(
      "2014-07" => [
        {
          "start_at"      => "2014-05-01T00:00:00+00:00",
          "end_at"        => "2014-05-31T23:59:59+00:00",
          "report_time"   => Time.now.iso8601,
          "type"          => "self-service-00",
          "database_service" => "https://api.engineyard.com/database_services/#{database_service.id}",
        },
      ]
    )
  end

  it "can fetch plan usage for an account and billing_month" do
    database_plan_usages = client.database_plan_usages.all(account_id: account.id, billing_month: "2014-07")

    expect(database_plan_usages.size).to eq(1)

    database_plan_usage = database_plan_usages.first

    expect(database_plan_usage.start_at).not_to be_nil
    expect(database_plan_usage.end_at).not_to be_nil
    expect(database_plan_usage.report_time).not_to be_nil

    expect(database_plan_usage.type).to eq("self-service-00")

    expect(database_plan_usage.database_service).to eq(database_service)
  end

end

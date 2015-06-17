require "spec_helper"

describe "plan_usage", :mock_only do
  let!(:client)  { create_client }
  let!(:account) { create_account(client: client, account: { owner: create_user(client: client)}) }

  before(:each) do
    Timecop.freeze(Time.parse("2014-06-04 09:13:39 -0800"))

    now             = Time.now
    billing_month   = now.strftime("%Y-%m")
    month_beginning = DateTime.new(now.year, now.month, 1)
    end_of_month    = DateTime.new(now.year, (now.month + 1) % 12, 1, 23, 59, 59) - 1

    client.data[:plan_usages][account.id].merge!(
    {
      "2014-05" => [
        {
          "start_at"     => "2014-05-01T00:00:00+00:00",
          "end_at"       => "2014-05-31T23:59:59+00:00",
          "type"         => "classic-00",
          "support"      => "premium",
          "server_limit" => nil,
          "flavor_limit" => nil,
        },
      ],
      billing_month => [
        {
          "start_at"     => month_beginning.iso8601,
          "end_at"       => end_of_month.iso8601, # still valid
          "type"         => "correct-type",
          "support"      => "premium",
          "server_limit" => nil,
          "flavor_limit" => nil,
        },
      ],
    })
  end

  it "can fetch plan usage for an account and billing_month" do
    plan_usages = client.plan_usages.all(account_id: account.id, billing_month: "2014-05")

    expect(plan_usages.size).to eq(1)

    plan_usage = plan_usages.first

    expect(plan_usage.start_at).not_to be_nil
    expect(plan_usage.end_at).not_to be_nil

    expect(plan_usage.type).to eq("classic-00")
    expect(plan_usage.support).to eq("premium")

    expect(plan_usage.server_limit).to be_nil
    expect(plan_usage.flavor_limit).to be_nil
  end

  it "defaults to the current billing_month" do
    plan_usages = client.plan_usages.all(account_id: account.id)

    expect(plan_usages.size).to eq(1)

    plan_usage = plan_usages.first
    expect(plan_usage.type).to eq("correct-type")
  end
end

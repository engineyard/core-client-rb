require "spec_helper"

RSpec.describe "Auto scaling alarms" do
  let!(:client) { create_client }
  let!(:account) { create_account(client: client) }
  let(:policy) { create_auto_scaling_policy }

  let(:params) do
    {
      "name" => SecureRandom.hex(16),
      "aggregation_type" => "avg",
      "metric_type" => "cpu",
      "operand" => "gt",
      "trigger_value" => 0.5,
      "number_of_periods" => 1,
      "period_length" => 30,
      "auto_scaling_policy_id" => policy.id
    }
  end

  let!(:alarm) { client.auto_scaling_alarms.create!(params).resource! }

  it "creates a new alarm for an auto scaling policy" do
    expect(alarm).not_to be_nil
    expect(policy.auto_scaling_alarms).not_to be_empty
    expect(client.auto_scaling_alarms).not_to be_empty
  end

  it "updates an alarm" do
    expect do
      alarm.update("name" => "new name")
    end.to change { alarm.name }.to("new name")
  end

  it "destroys auto scalig alarm by it's id" do
    expect do
      alarm.destroy!
    end.to change { policy.reload.auto_scaling_alarms.count }.from(1).to(0)
  end
end

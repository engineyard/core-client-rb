require "spec_helper"

RSpec.describe "Auto scaling policies" do
  let!(:client) { create_client }
  let!(:account) { create_account(client: client) }
  let!(:environment) { create_environment(account: account) }
  let(:auto_scaling_group) { create_auto_scaling_group(environment: environment.id) }

  describe "common requests for all policy types" do
    let(:params) do
      {
        auto_scaling_group_id: auto_scaling_group.id,
        action_value: 2,
        name: SecureRandom.hex(16),
        type: "simple"
      }
    end

    before do
      client.auto_scaling_policies.create!(params)
    end

    let!(:policy) { auto_scaling_group.simple_auto_scaling_policies.first }

    it "is able to retrieve auto scaling policy by it's id" do
      found_policy = client.auto_scaling_policies.get(policy.id)
      expect(found_policy).not_to be_nil
      expect(found_policy.id).to eq(policy.id)
    end

    it "updates auto scaling policy" do
      expect do
        policy.update(name: "new name")
      end.to change { policy.name }.to("new name")
    end

    it "destroys a policy by it's id" do
      expect do
        policy.destroy!
      end.to change { auto_scaling_group.reload.simple_auto_scaling_policies.count }.from(1).to(0)
    end
  end

  context "simple autoscaling policy" do
    let(:params) do
      {
        auto_scaling_group_id: auto_scaling_group.id,
        action_value: 2,
        name: SecureRandom.hex(16),
        type: "simple"
      }
    end

    it "adds one to autoscaling group" do
      expect {
        client.auto_scaling_policies.create!(params)
      }.to change { auto_scaling_group.reload.simple_auto_scaling_policies.count }.from(0).to(1)
        .and not_change { auto_scaling_group.reload.step_auto_scaling_policies.count }
        .and not_change { auto_scaling_group.reload.target_tracking_auto_scaling_policies.count }
    end
  end

  context "target tracking auto scaling policy" do
    let(:params) do
      {
        auto_scaling_group_id: auto_scaling_group.id,
        name: SecureRandom.hex(16),
        target_value: 0.7,
        metric_type: "avg_cup",
        disable_scale_in: false,
        type: "target"
      }
    end

    it "adds one to autoscaling group" do
      expect {
        client.auto_scaling_policies.create!(params)
      }.to change { auto_scaling_group.reload.target_tracking_auto_scaling_policies.count }.from(0).to(1)
        .and not_change { auto_scaling_group.reload.simple_auto_scaling_policies.count }
        .and not_change { auto_scaling_group.reload.step_auto_scaling_policies.count }
    end
  end

  context "step auto scaling policy" do
    let(:params) do
      {
        auto_scaling_group_id: auto_scaling_group.id,
        name:                  SecureRandom.hex(16),
        estimated_warmup:      200,
        action_unit:           "instances",
        action_type:           "add",
        steps:                 [{ metric_from: 50, metric_to: nil, action_value: 1 }],
        type:                  "step"
      }
    end

    it "adds one to autoscaling group" do
      expect {
        client.auto_scaling_policies.create!(params)
      }.to change { auto_scaling_group.reload.step_auto_scaling_policies.count }.from(0).to(1)
        .and not_change { auto_scaling_group.reload.simple_auto_scaling_policies.count }
        .and not_change { auto_scaling_group.reload.target_tracking_auto_scaling_policies.count }
    end
  end
end

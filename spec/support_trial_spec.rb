require 'spec_helper'

describe "account_trial" do
  let!(:client) { create_client }

  context "with an account", :mock_only do
    let!(:account) { create_account(client: client) }

    it "has no support trial" do
      expect(account.support_trial).to be_nil
    end

    it "returns support_trial if it has one" do
      Ey::Core::Client::Mock.support_trial_elibigle(client, account.id)
      account.reload
      trial = account.support_trial
      expect(trial).to be
      expect(trial.started_at).to be_nil
      expect(trial.expires_at).to be_nil
      expect(trial.account).to  eq(account)
    end

    it "returns support_trial if it has one" do
      Ey::Core::Client::Mock.support_trial_active(client, account.id)
      account.reload
      trial = account.support_trial
      expect(trial).to be
      expect(trial.started_at).to be
      expect(trial.expires_at).to be
      expect(trial.account).to  eq(account)
    end
  end
end

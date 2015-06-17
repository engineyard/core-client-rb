require 'spec_helper'

describe "account_trial" do
  let!(:client) { create_client }

  context "with an account", :mock_only do
    let!(:account) { create_account(client: client) }

    it "has trial data" do
      trial = account.account_trial

      expect(trial.duration).to eq(500)
      expect(trial.used).to     eq(30)
      expect(trial.account).to  eq(account)
    end
  end
end

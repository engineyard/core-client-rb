require 'spec_helper'

describe 'billing', :mock_only do
  let!(:consumer_client) { create_client }

  context "with account" do
    let!(:user)       { consumer_client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
    let!(:account)    { consumer_client.accounts.create!(owner: user, name_prefix: Faker::Name.first_name) }

    it "has billing state" do
      billing = consumer_client.billing.get(account.id)
      expect(billing.state).to eq "requested"
    end

    it "can update billing state" do
      billing = consumer_client.billing.get(account.id)
      billing.state = "verified"
      billing.save

      billing = consumer_client.billing.get(account.id)
      expect(billing.state).to eq "verified"

      billing = consumer_client.billing.put_state(account.id, "finalized")
      expect(billing.state).to eq "finalized"

      billing = consumer_client.billing.get(account.id)
      expect(billing.state).to eq "finalized"
    end

  end
end

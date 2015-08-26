require 'spec_helper'

describe 'slots' do
  describe "as a user" do
    let!(:client) { create_client }
    let(:client)       { create_client }

    let!(:account) do
      hmac_account = client.accounts.create!(owner: user, name: Faker::Name.first_name, type: "beta")
      client.accounts.get(hmac_account.id)
    end
    let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
    let!(:provider)    { account.providers.all.first || account.providers.create!(type: "aws").resource! }
    let!(:user)        { client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
    let!(:cluster) { environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-east-1") }


    describe "with a slot" do
      let!(:slot) { cluster.slots.create(quantity: 1).first }

      it "should be able to retire a slot" do
        slot.retire
        expect(slot.retired_at).to be
      end

      it "should be able to disable a slot" do
        slot.disable
        expect(slot.disable_requested_at).to be
      end
    end
  end
end

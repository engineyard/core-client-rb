require 'spec_helper'

describe 'providers' do
  context "with a hmac client" do
    let!(:client)  { create_client }
    let!(:account) { create_account(client: client) }

    ["azure", "aws"].each do |provider|
      it "has possible #{provider} locations without a provider type" do
        locations = client.provider.possible_locations(provider)
        expect(locations).to be_a(Array)
        expect(locations).not_to be_empty
      end
    end

    context "with an account" do
      ["aws"].each do |type|
        it "creates a #{type} provider" do
          provisioned_id = SecureRandom.hex(8)
          provider = account.providers.create!(type: type, provisioned_id: provisioned_id, credentials: {}).resource!

          expect(provider.account).to        eq(account)
          expect(provider.type).to           eq(type)
          expect(provider.provisioned_id).to eq(provisioned_id)
        end

        context "with a #{type} provider" do
          let!(:provider) { account.providers.create!(type: type, provisioned_id: SecureRandom.hex(8), credentials: {}).resource! }

          it "gets an provider" do
            expect(account.providers.get(provider.id)).to eq(provider)
          end

          it "has possible provider locations" do
            expect(provider.possible_locations).to be_a(Array)
            expect(provider.possible_locations).not_to be_empty
          end

          it "gets providers" do
            another_account = create_account(client: client)
            create_provider(account: another_account)

            account_providers = account.providers.all

            expect(account_providers.size).to eq(1)
            expect(account_providers.first).to eq(provider)
          end

          it "destroys the provider" do
            expect(provider.destroy.ready!).to be_successful
            expect(provider.reload.cancelled_at).not_to be_nil
          end

          it "discovers locations for the #{type} provider", :mock_only do
            provider.possible_locations.each do |location_id|
              provider_location = nil
              expect {
                provider_location = provider.provider_locations.discover(location_id).resource!
                expect(provider_location).to be_a(Ey::Core::Client::ProviderLocation)
                expect(provider_location.location_id).to eq(location_id)
              }.to change { provider.provider_locations.all.reload.count }
            end
          end
        end
      end
    end

    context "with two clients pointed to the same cloud", :mock_only do
      let!(:client_1) { create_client(url: "http://client.example.com") }
      let!(:owner)    { client_1.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
      let!(:client_1_account_1) { client_1.accounts.create!(owner: owner, name: Faker::Name.first_name)}
      let!(:client_1_account_2) { client_1.accounts.create!(owner: owner, name: Faker::Name.first_name)}

      it "does not clobber other accounts' providers" do
        # this just tests that the mock behaves reasonably
        client_1_account_1.providers.create!(type: "aws").ready!

        expect(client_1_account_1.providers.all.count).to eq(1)
        expect(client_1_account_2.providers.all.count).to eq(0)

        client_1_account_2.providers.create!(type: "aws").ready!

        expect(client_1_account_1.providers.all.count).to eq(1)
        expect(client_1_account_2.providers.all.count).to eq(1)

        client_2 = create_client(url: "http://client.example.com")

        client_2_account_1 = client_2.accounts.get(client_1_account_1.id)
        expect(client_2_account_1).not_to be_nil
        client_2_account_2 = client_2.accounts.get(client_1_account_2.id)
        expect(client_2_account_2).not_to be_nil

        client_2_account_2.providers.create!(type: "aws").ready!

        expect(client_1_account_1.providers.all.count).to eq(1)
        expect(client_2_account_1.providers.all.count).to eq(1)
        expect(client_1_account_2.providers.all.count).to eq(2)
        expect(client_2_account_2.providers.all.count).to eq(2)

        expect(client_1.providers.count).to eq(3)
        expect(client_2.providers.count).to eq(3)
      end
    end
  end
end

require 'spec_helper'

describe 'provider locations' do
  context "with a hmac client" do
    let!(:client)   { create_client }
    let!(:account)  { create_account(client: client) }
    let!(:provider) { create_provider(account: account) }

    let!(:provider_location) do
      if Ey::Core::Client.mocking?
        create_provider_location(client,
                                 :location_name => "Eastern United States",
                                 :location_id   => "us-east-1",
                                 :provider      => provider,
                                 :limits        => {"servers" => 20, "addresses" => 5}
                                )
      else
        provider.provider_locations.first
      end
    end

    before do
    end

    it "should find the provider location" do
      location = client.provider_locations.get(provider_location.id)

      expect(location.id).to eq(provider_location.id)
      expect(location.location_name).to eq(provider_location.location_name)
      expect(location.location_id).to eq(provider_location.location_id)
      expect(location.limits["servers"]).to eq(provider_location.limits["servers"])
      expect(location.limits["addresses"]).to eq(provider_location.limits["addresses"])
    end

    context "with a provider" do
      let!(:another_provider) { create_provider(client: client, account: account) }
      let!(:another_location) do
        if Ey::Core::Client.mocking?
          create_provider_location(client,
                                   :provider      => another_provider,
                                   :location_name => "Western United States",
                                   :location_id   => "us-west-1",
                                   :limits        => {"servers" => 20, "addresses" => 5})
        else
          provider.provider_locations.last
        end
      end

      it "should list provider locations" do
        locations = provider.provider_locations.all

        expect(locations.size).to be > 0

        location = locations.first(location_id: provider_location.location_id)

        expect(location.id).to eq(provider_location.id)
        expect(location.location_name).to eq(provider_location.location_name)
        expect(location.location_id).to eq(provider_location.location_id)
        expect(location.limits["servers"]).to eq(provider_location.limits["servers"])
        expect(location.limits["addresses"]).to eq(provider_location.limits["addresses"])
      end
    end
  end
end

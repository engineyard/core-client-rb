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

    it "finds the provider location" do
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

      it "lists provider locations" do
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

    describe '#limits=' do
      let(:new_limits) {{servers: 25, addresses: 10}}

      it 'sets new limits for the provider location' do
        provider_location.limits = new_limits

        expect(provider_location.limits).to eql(new_limits)
      end

      it 'is persisted when saved' do
        limits = {"servers" => 20, "addresses" => 5}
        provider_location.limits = new_limits

        expect(provider.provider_locations.get(provider_location.id).limits).to eql(limits)

        provider_location.save!

        expect(provider.provider_locations.get(provider_location.id).limits).to eql(new_limits)
      end
    end
  end
end

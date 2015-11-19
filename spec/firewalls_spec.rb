require 'spec_helper'

describe "firewalls" do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { create_environment(account: account, name: Faker::Name.first_name) }

  it "creates a firewall" do
    pending "Not implemented"

    name     = Faker::Name.first_name
    location = "us-west-2"

    firewall = client.firewalls.create!(
      :provider    => provider,
      :name        => name,
      :location    => location,
      :environment => environment.id,
    ).resource!

    expect(firewall.id).not_to be_nil
    expect(firewall.provisioned_id).not_to be_nil
    expect(firewall.provider).to eq(provider)
    expect(firewall.name).to     eq(name)
    expect(firewall.location).to eq(location)
    expect(firewall.environment).to eq(environment)
  end

  context "with a firewall" do
    before(:each) { pending "Not implemented" }

    let!(:firewall) { client.firewalls.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2", environment: environment.id).resource! }

    it "destroys a firewall" do
      firewall.destroy.ready!

      expect(firewall.reload.deleted_at).not_to be_nil
    end

    it "should create a rule" do
      rule = client.firewall_rules.create!(
        :firewall_id => firewall.id,
      ).resource!

      expect(rule.source).to eq("0.0.0.0/0")
      expect(rule.port_range).to eq(0..65535)
    end

    it "creates a rule with a firewall as the source" do
      other_firewall = client.firewalls.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2").resource!

      rule = client.firewall_rules.create!(
        :firewall_id => firewall.id,
        :source      => other_firewall.id,
        :port_range  => "80-443",
      ).resource!

      expect(rule.source.to_i).to     eq(other_firewall.id)
      expect(rule.source_firewall).to eq(other_firewall)
      expect(rule.port_range).to      eq(80..443)
    end

    context "with a firewall rule" do
      let!(:rule) { client.firewall_rules.create!(firewall_id: firewall.id).resource! }

      it "destroys a rule" do
        expect { rule.destroy.ready! }.to change { client.firewall_rules.all.size }.by(-1)
        expect(rule.reload.deleted_at).not_to be_nil
      end

      it "is part of the firewall's rules list" do
        expect(firewall.rules.count).to eq(1)
        expect(firewall.rules.first.id).to eq(rule.id)
      end
    end
  end

  context "with multiple firewalls" do
    it "lists all firewalls"
    it "lists firewalls by name"
    it "lists a firewall's rules"
  end
end

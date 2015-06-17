require 'spec_helper'

describe "firewalls" do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
  let!(:cluster)     { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }

  it "should create a firewall" do
    name     = Faker::Name.first_name
    location = "us-west-2"

    firewall = client.firewalls.create!(
      :provider   => provider,
      :name       => name,
      :location   => location,
      :cluster    => cluster.id,
    ).resource!

    expect(firewall.id).not_to be_nil
    expect(firewall.provisioned_id).not_to be_nil
    expect(firewall.clusters.all).to match_array([cluster])
    expect(firewall.provider).to eq(provider)
    expect(firewall.name).to     eq(name)
    expect(firewall.location).to eq(location)
  end

  context "with a firewall" do
    let!(:firewall) { client.firewalls.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2", cluster: cluster.id).resource! }

    it "should destroy a firewall" do
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

    it "should create a rule with a firewall as the source" do
      other_firewall = client.firewalls.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2", cluster: cluster.id).resource!

      rule = client.firewall_rules.create!(
        :firewall_id => firewall.id,
        :source      => other_firewall.id,
        :port_range  => "80-443",
      ).resource!

      expect(rule.source.to_i).to     eq(other_firewall.id)
      expect(rule.source_firewall).to eq(other_firewall)
      expect(rule.port_range).to      eq(80..443)
    end

    it "should list a server's firewalls" do
      slot = cluster.slots.create(quantity: 1).first
      cluster.cluster_updates.create!.ready!
      server = slot.reload.server

      another_cluster = client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-east-1")
      another_slot = another_cluster.slots.create(quantity: 1).first
      another_cluster.cluster_updates.create!.ready!
      another_slot.reload.server

      expect(server.firewalls).to match_array(cluster.firewalls)
    end

    context "with a firewall rule" do
      let!(:rule) { client.firewall_rules.create!(firewall_id: firewall.id).resource! }

      it "should destroy a rule" do
        expect { rule.destroy.ready! }.to change { client.firewall_rules.all.size }.by(-1)
        expect(rule.reload.deleted_at).not_to be_nil
      end

      it "should be part of the firewall's rules list" do
        expect(firewall.rules.count).to eq(1)
        expect(firewall.rules.first.id).to eq(rule.id)
      end
    end
  end

  context "with multiple firewalls" do
    it "should list all firewalls"
    it "should list firewalls by name"
    it "should list an cluster's firewalls" # multiple cluster test?
    it "should list a firewall's rules"
  end
end

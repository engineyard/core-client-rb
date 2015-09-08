require 'spec_helper'

describe Ey::Core::Client do
  let!(:client)   { create_client }
  let!(:account)  { create_account(client: client) }
  let!(:provider) { create_provider(account: account) }

  it "creates a deis cluster" do
    deis_cluster = nil

    expect {
      deis_cluster = account.deis_clusters.create!(name: SecureRandom.hex(6))
    }.to change { account.deis_clusters.all.count }.by(1)

    expect(client.deis_clusters.all).to contain_exactly(deis_cluster)
  end

  context "with a deis cluster" do
    let!(:cluster) { account.deis_clusters.create!(name: SecureRandom.hex(6)) }

    it "fetches a the cluster" do
      expect(client.deis_clusters.get!(cluster.identity)).to eq(cluster)
    end

    context "with an agent", :mock_only do
      let!(:agent) { client.add_agent(cluster) }

      it "lists cluster's agents" do
        expect(cluster.agents.all).to contain_exactly(agent)
      end

      it "lists agent's alerts" do
        alert = nil
        expect {
          alert = agent.alerts.create!(
            :description => SecureRandom.hex(6),
            :finished_at => nil, # never finish
            :message     => SecureRandom.uuid,
            :name        => SecureRandom.uuid,
            :external_id => SecureRandom.uuid,
            :severity    => "warning",
          )
        }.to change { agent.alerts.size }.by(1)

        alert = client.alerts.get!(alert.identity)

        expect(alert.agent).to eq(agent)
      end
    end
  end
end

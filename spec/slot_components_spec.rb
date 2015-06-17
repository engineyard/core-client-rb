require 'spec_helper'

describe 'slot components' do
  describe "as a user" do
    let!(:hmac_client) { create_hmac_client }
    let!(:client)       { create_client }
    let!(:user)        { hmac_client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
    let!(:account) do
      hmac_account = hmac_client.accounts.create!(owner: user, name: Faker::Name.first_name, type: "beta")
      client.accounts.get(hmac_account.id)
    end

    context "with an environment" do
      let!(:environment)       { account.environments.create!(account: account, name: Faker::Name.first_name) }
      let!(:provider)          { account.providers.all.first || account.providers.create!(type: "aws").resource! }
      let!(:facet_config)      { { "facets" => [ {"type" => "ruby" }, { "type" => "web_server" } ] } }
      let!(:default_component) { client.components.first(name: "cluster_cookbooks") }
      let!(:cluster)           { environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-east-1") }
      let!(:cluster_component) { cluster.cluster_components.create!(component: default_component, configuration: facet_config ) }
      let!(:slot)              { cluster.slots.create(quantity: 2).first }

      describe "a slot component" do
        subject { slot.slot_components.first }


        it "can be retrieved?" do
          expect(subject.component).to eq(default_component)
          expect(subject.configuration["facets"].map {|f| f["type"]}).to include("ruby", "web_server")
        end

        it "can be updated" do
          ruby_facet = subject.configuration["facets"].detect {|facet| facet["type"] == "ruby" }
          expect(ruby_facet).to be

          ruby_facet["ruby_version"] = "2.1.0"
          ruby_facet[:whatever] = "something"
          subject.save
          subject.reload

          ruby_facet = subject.configuration["facets"].detect {|facet| facet["type"] == "ruby" }
          expect(ruby_facet["ruby_version"]).to eq("2.1.0")
          expect(ruby_facet["whatever"]).to eq("something")
        end
      end

      describe "searching slot components" do
        let!(:other_cluster)           { environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-east-1") }
        let!(:other_cluster_component) { other_cluster.cluster_components.create!(component: default_component, configuration: facet_config ) }
        let!(:other_slot)              { other_cluster.slots.create(quantity: 2).first }
        let!(:other_environment) do
          e = account.environments.create!(account: account, name: Faker::Name.first_name)
          c = e.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-east-1")

          c.cluster_components.create!(component: default_component, configuration: facet_config)
          c.slots.create(quantity: 2)

          e
        end

        it "searches by slot" do
          expect(slot.slot_components.size).to eq(1)
          expect(slot.slot_components.first.slot).to eq(slot)
        end

        it "searches by cluster" do
          slot_components = client.slot_components.all(cluster: cluster.id).to_a
          expect(slot_components.size).to eq(2)
          slot_components.each {|sc| expect(sc.slot.cluster).to eq(cluster) }
        end

        it "searches by environment" do
          slot_components = client.slot_components.all(environment: environment.id).to_a
          expect(slot_components.size).to eq(4)
          slot_components.each {|sc| expect(sc.slot.cluster.environment).to eq(environment) }

          slot_components = client.slot_components.all(environment: other_environment.id).to_a
          expect(slot_components.size).to eq(2)
          slot_components.each {|sc| expect(sc.slot.cluster.environment).to eq(other_environment) }
        end
      end
    end
  end
end

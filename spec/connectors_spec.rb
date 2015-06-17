require 'spec_helper'

describe 'connectors' do
  describe "as a user" do
    let!(:environment) { create_environment(account: account, client: client) }
    let!(:provider)    { create_provider(account: account, client: client) }
    let!(:account)     { create_account(client: client) }
    let!(:client)      { create_client }

    it "should create a connector" do
      default_component = client.components.first(name: "cluster_cookbooks")

      web_cluster   = environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2")
      mysql_cluster = environment.clusters.create!(provider: provider, name: Faker::Name.first_name, location: "us-west-2")

      www           = web_cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :ruby}, {type: :web_server}]})
      mysql         = mysql_cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :mysql}]})
      configuration = {
        "facet"    => "mysql",
        "name"     => "tasha",
        "password" => "ines",
        "username" => "thom",

      }
      connector = mysql.connect(www, configuration)

      expect(connector.source).to eq(mysql)
      expect(connector.destination).to eq(www)
      expect(connector.configuration).to eq(configuration)
    end

    context "with a connector" do
      let!(:environment) { load_blueprint(client: client).last }
      let!(:connector)   { environment.clusters.last.cluster_components.last.connectors.last }

      it "should update a connectors configuration" do
        expect {
          connector.update(:configuration => {"foo" => "bar"})
        }.to change { connector.reload.configuration }.from({}).to({"foo" => "bar"})
      end
    end

    describe "with multiple connectors & clusters" do
      it "should list all connectors"
      it "should list a cluster's connectors"
    end
  end
end

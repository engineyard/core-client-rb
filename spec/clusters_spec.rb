require 'spec_helper'

describe 'clusters' do
  describe "as a user" do
    let!(:client)      { create_client }
    let!(:account)     { create_account }
    let!(:environment) { create_environment(account: account, client: client)}
    let!(:provider)    { create_provider(account: account, client: client) }
    let!(:user)        { create_user }

    it "should create a cluster" do
      name = Faker::Name.first_name
      location = "us-west-2"
      cluster = environment.clusters.create!(provider: provider, name: name, location: location)

      expect(cluster.environment).to    eq(environment)
      expect(cluster.provider).to       eq(provider)
      expect(cluster.name).to           eq(name)
      expect(cluster.location["id"]).to eq(location)

      cluster_configuration = cluster.configuration
      expect(cluster_configuration["version"]).to eq(0)

      expect(cluster_configuration["firewalls"].size).to eq(1)
      firewall = cluster_configuration["firewalls"].first
      expect(firewall["name"]).to eq("#{cluster.identity[0..6]}-firewall")

      expect(firewall["rules"].size).to eq(1)
      rule = firewall["rules"].first
      rule["source.should"] == "0.0.0.0/0"
      expect(rule["port_range"]).to eq("22")

      default_cookbooks = client.components.first(name: "default_cookbooks")
      expect(default_cookbooks).not_to be_nil
      expect(default_cookbooks.name).to eq("default_cookbooks")

      riak_cluster_component = cluster.cluster_components.create!(component: default_cookbooks, configuration: {facets: [{type: :riak}]})
      expect(cluster.cluster_components.all).to match_array([riak_cluster_component])

      cluster.slots.create(quantity: 5)

      update_request = cluster.cluster_updates.create!

      cluster_update = update_request.resource!
      expect(cluster_update).not_to be_nil
      expect(cluster_update.cluster).to eq(cluster)
      expect(cluster_update.stage).to be
      expect(cluster_update.logs.all.size).to eq(5)

      expect(cluster.slots.all.size).to eq(5)
      cluster.slots.all.each do |slot|
        expect(slot.server).not_to be_nil
        expect(slot.name).not_to be_nil
      end

      expect(cluster.servers.all.size).to eq(5)
      cluster.servers.all.each do |server|
        expect(server.flavor_id).not_to be_nil
        expect(server.name).not_to be_nil
        expect(server.private_hostname).not_to be_nil
        expect(server.public_hostname).not_to be_nil
        expect(server.slot).not_to be_nil
        expect(server.ssh_port).not_to be_nil
        expect(server.state).to eq("running")
      end

      firewall = cluster.firewalls.one
      expect(firewall.name).to include("firewall")

      rules = firewall.rules.all.map { |r| { source: r.source, port_range: r.port_range } }
      expect(rules).to include(
        { source: "0.0.0.0/0", port_range: 22..22 },
      )
    end

    context "when using the azure provider" do
      let(:provider) { create_provider(client: client, provider: {type: :azure}) }

      it "should create an azure cluster" do #make sure configuration is the same for awsm and the mock
        name = Faker::Name.first_name
        location = "East US"
        cluster = environment.clusters.create!(provider: provider, name: name, location: location)

        expect(cluster.environment).to    eq(environment)
        expect(cluster.provider).to       eq(provider)
        expect(cluster.name).to           eq(name)
        expect(cluster.location["id"]).to eq(location)

        cluster_configuration = cluster.configuration
        expect(cluster_configuration["version"]).to eq(0)

        expect(cluster_configuration).not_to have_key "firewalls"
        expect(cluster_configuration["hosted_services"].size).to eq(1)
        hosted_service = cluster_configuration["hosted_services"].first
        expect(hosted_service["name"]).to eq("#{cluster.identity[0..6]}-hosted-service")
        expect(hosted_service["endpoints"]).to eq([])

        default_cookbooks = client.components.first(name: "default_cookbooks")

        cluster.cluster_components.create!(component: default_cookbooks, configuration: {facets: [{type: :riak}]})

        cluster.slots.create(names: %w[one two three])

        update_request = cluster.cluster_updates.create!

        cluster_update = update_request.resource!
        expect(cluster_update).not_to be_nil
        expect(cluster_update.cluster).to eq(cluster)
      end
    end

    it "should create a cluster with given slot names" do
      name = Faker::Name.first_name
      location = "us-west-2"
      cluster = environment.clusters.create!(provider: provider, name: name, location: location)

      expect(cluster.environment).to    eq(environment)
      expect(cluster.provider).to       eq(provider)
      expect(cluster.name).to           eq(name)
      expect(cluster.location["id"]).to eq(location)

      cluster_configuration = cluster.configuration
      expect(cluster_configuration["version"]).to eq(0)

      expect(cluster_configuration["firewalls"].size).to eq(1)
      firewall = cluster_configuration["firewalls"].first
      expect(firewall["name"]).to eq("#{cluster.identity[0..6]}-firewall")

      expect(firewall["rules"].size).to eq(1)
      rule = firewall["rules"].first
      rule["source.should"] == "0.0.0.0/0"
      expect(rule["port_range"]).to eq("22")

      default_cookbooks = client.components.first(name: "default_cookbooks")
      expect(default_cookbooks).not_to be_nil
      expect(default_cookbooks.name).to eq("default_cookbooks")

      cluster.cluster_components.create!(component: default_cookbooks, configuration: {facets: [{type: :riak}]})

      cluster.slots.create(names: %w[one two three])

      update_request = cluster.cluster_updates.create!

      cluster_update = update_request.resource!
      expect(cluster_update).not_to be_nil
      expect(cluster_update.cluster).to eq(cluster)
      expect(cluster_update.logs.all.size).to eq(3)

      expect(cluster.slots.all.size).to eq(3)
      cluster.slots.all.each do |slot|
        expect(slot.server).not_to be_nil
        expect(slot.name).not_to be_nil
      end
      expect(cluster.slots.all.map(&:name).sort).to eq(%w[one three two])

      expect(cluster.servers.all.size).to eq(3)
      cluster.servers.all.each do |server|
        expect(server.flavor_id).not_to be_nil
        expect(server.name).not_to be_nil
        expect(server.private_hostname).not_to be_nil
        expect(server.public_hostname).not_to be_nil
        expect(server.slot).not_to be_nil
        expect(server.ssh_port).not_to be_nil
        expect(server.state).to eq("running")
      end
      expect(cluster.servers.all.map(&:name).sort).to eq(%w[one three two])
    end

    describe "with a cluster" do
      let!(:cluster) { client.clusters.create(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }

      context "with some updates" do
        let!(:update) { create_cluster_update(cluster: cluster, client: client) }
        let!(:_)      { create_cluster_update(client: client) }

        it "should find updates by cluster" do
          expect(
            client.cluster_updates.all(cluster: cluster.id)
          ).to contain_exactly(update)
        end
      end

      it "should get a cluster" do
        expect(client.clusters.get(cluster.identity)).to eq(cluster)
      end

      it "should update a cluster's release label" do
        release_label = cluster.release_label = "ubuntu-precise-0.4"
        cluster.save!
        expect(client.clusters.get(cluster.identity).release_label).to match(release_label)
      end

      it "should update a cluster's configuration" do
        configuration = cluster.configuration = cluster.configuration.merge("michelle" => "noorali")
        cluster.save!
        expect(cluster.configuration).to eq(configuration)
        expect(client.clusters.get(cluster.identity).configuration).to eq(configuration)
      end

      it "should add and update a cluster component" do
        default_cookbooks = client.components.first(name: "default_cookbooks")
        cluster_component = cluster.cluster_components.create!(component: default_cookbooks, configuration: {facets: [{type: :postgresql}]})
        cluster_component.configuration["facets"].first["myconfig"] = "foo"
        cluster_component.save
        expect(client.cluster_components.get(cluster_component.identity).configuration["facets"].first["myconfig"]).to eq("foo")
      end

      it "should be able to delete a slot when marked retired" do
        slot = cluster.slots.create(quantity: 1, flavor: "large", image: "dpiddy").first
        slot.retire
        cluster.cluster_updates.create!.ready!
        expect(cluster.slots.size).to eq(0)
      end

      it "should list all clusters" do
        clusters = client.clusters.all

        expect(clusters).to include(cluster)
      end

      describe "with another environment & cluster" do
        let!(:another_environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
        let!(:another_cluster) { another_environment.clusters.create(provider: provider, name: "second_cluster", location: "us-west-2") }

        it "should list an environment's clusters" do
          expect(environment.clusters.all).to match_array([cluster])
        end

        it "should find a cluster by name" do
          expect(client.clusters.all(name: cluster.name)).to match_array([cluster])
        end

        it "should destroy a cluster" do
          expect {
            cluster.destroy.ready!
          }.to change { cluster.reload.deleted_at }.from(nil)
        end
      end
    end

    context "with an app cluster" do
      let!(:application) { account.applications.first(account: account.id, name: "todo") || account.applications.create!(name: :todo, type: "rails3", repository: "git://github.com/engineyard/todo.git") }
      let!(:cluster) {
        client.clusters.create!(
          provider: provider,
          location: "us-west-2",
          environment: environment,
          name: "www",
          release_label: "ubuntu-1.1",
          configuration: {
            slot: {
              volumes: [{
                device:        "/dev/xvdm",
                file_system:   "ext4",
                mount:         "/data",
                mount_options: "noatime",
                size:          25,
              }]
            },
            firewalls: [{
              name: "#{SecureRandom.hex(3)}-firewall",
              rules: [
                { source: "0.0.0.0/0", port_range: "80" },
                { source: "0.0.0.0/0", port_range: "443" },
              ],
            }],
          }
        )
      }

      before(:each) do
        default_component = client.components.first(name: "cluster_cookbooks")
        expect(default_component).not_to be_nil
        default_application_component = client.components.first(name: "default_deployer")
        expect(default_application_component).not_to be_nil

        cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :ruby}, {type: :web_server}]})
        cluster.cluster_components.create!(component: default_application_component, configuration: {application: application.id})
        cluster.slots.create(quantity: 2, flavor: "large", image: "dpiddy")
        cluster.cluster_updates.create!.ready!
      end

      it "should deploy an application" do
        task = cluster.deploy(application, foo: "bar").resource!
        expect(task.action).to eq("deploy")
        expect(task.configuration["foo"]).to eq("bar")
      end

      it "should run any app action" do
        %w[deploy enable disable restart].each do |action|
          task = cluster.run_action(application, action, foo: "bar").resource!
          expect(task.action).to eq(action)
          expect(task.configuration["foo"]).to eq("bar")
        end
      end

      it "should create /data volumes" do
        cluster.slots.each do |slot|
          expect(slot.server).to be
          slot.server.volumes.all(mount: "/data").one
        end
      end

      it "should have a firewall" do
        firewall = cluster.firewalls.one
        expect(firewall.name).to include("firewall")

        rules = firewall.rules.all.map {|rule| { source: rule.source, port_range: rule.port_range } }
        expect(rules).to include(
          { source: "0.0.0.0/0", port_range: 80..80 },
          { source: "0.0.0.0/0", port_range: 443..443 },
        )
      end
    end

    context "with a mysql cluster" do
      let!(:cluster) {
        client.clusters.create!(
          provider: provider,
          location: "us-west-2",
          environment: environment,
          name: "mysql",
          release_label: "ubuntu-1.1",
          configuration: {
            slot: {
              volumes: [{
                device:        "/dev/xvdn",
                file_system:   "ext4",
                mount:         "/db",
                mount_options: "noatime",
                size:          25,
              }]
            },
          }
        )
      }
      let(:cluster_component) { @cluster_component }

      before(:each) do
        default_component = client.components.first(name: "cluster_cookbooks")

        @cluster_component = cluster.cluster_components.create!(component: default_component, configuration: {facets: [{type: :mysql}]})
        cluster.slots.create(quantity: 2, flavor: "large")
        cluster.cluster_updates.create!.ready!
      end

      it "should backup a cluster", :mock_only do
        expect {
          cluster_component.run("backup")
        }.to change { cluster.backups.reload.count }.by(1)
      end

      it "should subscribe", :mock_only do
        expect(cluster_component.run("backup").read_channel).not_to be_nil

        begin
          timeout(0.1) { cluster_component.run("backup").subscribe { } }
        rescue Timeout::Error, EventMachine::ConnectionNotBound # handle mock urls
        end
      end

      it "should create /db volumes" do
        cluster.slots.each do |slot|
          expect(slot.server).to be
          volume = slot.server.volumes.one
          expect(volume.mount).to eq("/db")
        end
      end
    end
  end
end

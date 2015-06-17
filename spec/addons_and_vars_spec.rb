require 'spec_helper'

describe 'addons' do
  let!(:client) { create_client }

  context "with user and account" do
    let!(:account) { create_account(client: client) }

    it "list addons" do
      expect(account.addons.all).to be_empty
    end

    describe "create addon" do
      before do
        @addon = account.addons.create!(
          :name => "fooooo",
          :sso_url => "http://example.com",
          :vars => {foo: "bar", baz: "bob"})
      end

      it "creates the addon" do
        expect(@addon.name).to eq "fooooo"
        expect(@addon.sso_url).to eq "http://example.com"
        expect(@addon.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      it "shows in the list" do
        expect(account.addons.all.size).to eq 1
        addon = account.addons.first
        expect(addon.name).to eq "fooooo"
        expect(addon.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      it "can be fetched" do
        addon_refetched = account.addons.get(@addon.id)
        expect(addon_refetched.id).to eq @addon.id
        expect(addon_refetched.name).to eq "fooooo"
        expect(addon_refetched.vars).to eq({"foo" => "bar", "baz" => "bob"})
      end

      #Effectively also tests that the resource_url is set in all the ways an addon can be fetched
      it "can be updated (3 ways)" do
        tryit = Proc.new do |add, name, vars|
          add.name = name
          add.vars = vars
          add.save!
          add.reload
          expect(add.name).to eq name
          expect(add.vars).to eq vars
        end
        tryit.call(account.addons.get(@addon.id), "fetchedwithget", "fetchsingle" => "GET")
        tryit.call(account.addons.first, "fetchedfromlist", "fetchmulti" => "GET")
        tryit.call(@addon, "createresult", "created" => "POST")
      end

      it "can be destroyed" do
        @addon.destroy
        expect(account.addons.all.size).to eq 0
      end

      it "has no attachments available" do
        expect(@addon.attachments.all).to be_empty
      end

      describe "with an app and environment and cluster" do
        let(:app_name)       { Faker::Lorem.word }
        let(:repository)     { "#{Faker::Name.first_name}@#{Faker::Internet.domain_name}:#{app_name}/#{app_name}.git" }
        let(:app)            { account.applications.create!(name: app_name, type: "rails3", repository: repository) }
        let(:env)            { account.environments.create(name: Faker::Name.first_name) }
        let!(:provider)      { create_provider(account: account) }
        let!(:cluster)       { env.clusters.create!(provider: provider, name: 'application', location: "us-west-2") }
        let!(:app_component) { client.components.first(name: "default_deployer") }
        #TODO: shouldn't need to set cluster_id, it should be able to get that from the URL
        let!(:cluster_app)   { cluster.cluster_components.create!(component: app_component, configuration: {application: app.id}) }

        it "should only return addons with app" do
          component = client.components.first(name: "cluster_cookbooks")
          expect {
            cluster.cluster_components.create!(component: component, confiugration: {})
          }.not_to change { client.addon_attachments.all(account_id: account.id).size }
        end

        it "has one possible attachment point" do
          expect(@addon.attachments.all.size).to eq 0
          available_attachments = client.addon_attachments.all(account_id: account.id)
          expect(available_attachments.size).to eq 1
          attachment = available_attachments.first
          expect(attachment.app_id).to eq app.id
          expect(attachment.environment_id).to eq env.id
          expect(attachment.key).to be_nil
          expect(attachment.suggested_name).to eq "#{env.name}_#{app.name}"
        end

        describe "attaching addon" do
          before do
            attachment_id = client.addon_attachments.first(account_id: account.id).id
            @attachment = @addon.attachments.get(attachment_id)
            @attachment.attach!("my_foo")
          end

          it "creates a connector" do
            core_cluster = client.clusters.get(cluster.id)
            core_cluster_componenet = core_cluster.cluster_components.get(cluster_app.id)

            connectors = client.connectors.all(:cluster_component => core_cluster_componenet.id)
            expect(connectors.size).to eq 1
            connector = connectors.first
            expect(connector.configuration).to eq("key" => "my_foo")
            expect(connector.source).to eq @addon
            expect(connector.destination).to eq core_cluster_componenet
          end

          it "is attached (can be fetched individually or in a list)" do
            refetched = @addon.attachments.get(@attachment.id)
            expect(refetched).to eq @attachment
            expect(refetched.key).to eq "my_foo"
            first = @addon.attachments.first
            expect(first).to eq @attachment
            expect(first.key).to eq "my_foo"
          end

          it "attachment key can be updated (3 ways)", :mock_only do
            tryit = Proc.new do |att, key|
              att.key = key
              att.save!
              att.reload
              expect(att.key).to eq key
            end
            tryit.call(@addon.attachments.get(@attachment.id), "fetched_foo")
            tryit.call(@addon.attachments.first, "list_first_foo")
            tryit.call(@attachment, "attach_result_foo")
          end

          describe "when detached" do
            before do
              @attachment.detach!
            end

            it "destroy the connector" do
              skip unless Ey::Core::Client.mocking? # @fixme
              core_cluster = client.clusters.get(cluster.id)
              core_cluster_componenet = core_cluster.cluster_components.get(cluster_app.id)

              connectors = client.connectors.all(:cluster_component => core_cluster_componenet.id)
              expect(connectors.size).to eq 0
            end

            it "is detached", :mock_only do
              expect(@addon.attachments.size).to eq 0
            end
          end
        end
      end
    end
  end
end

require 'spec_helper'

describe 'as a user' do
  let!(:client) { create_client }

  context "with an environment" do
    let!(:account)     { create_account(client: client) }
    let!(:provider)    { create_provider(account: account) }
    let!(:app)         { create_application(account: account, client: client) }
    let!(:environment) { create_environment(client: client, account: account, application: app, configuration: { type: "production"}) }

    it "adds an auto scaling group" do
      expect {
        client.auto_scaling_groups.create!(minimum_size: 2, maximum_size: 6, environment: environment).resource!
      }.to change { environment.reload.auto_scaling_group }.from(nil).and change { client.auto_scaling_groups.count }.by(1)
    end

    context "with an auto scaling group" do
      let!(:group) { client.auto_scaling_groups.create!(minimum_size: 2, maximum_size: 6, environment: environment).resource! }

      it "destroys the auto scaling group" do
        expect {
          group.destroy.ready!
        }.to change { group.reload.deleted_at }.from(nil).and change { client.environments.get(environment.id).auto_scaling_group }.to(nil)
      end
    end
  end
end

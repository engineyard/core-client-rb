require 'spec_helper'

describe 'as a user' do
  let!(:client) { create_client }

  context "with a blueprint" do
    let!(:account)     { create_account(client: client) }
    let!(:provider)    { create_provider(account: account) }
    let!(:app)         { create_application(account: account, client: client) }
    let!(:environment) { create_environment(account: account, app: app, environment: { name: SecureRandom.hex(3)}, configuration: { type: "production"}) }
    let!(:blueprint)   { environment.save_blueprint("name" => SecureRandom.hex(3)) }

    it "changes the name" do
      name = SecureRandom.hex(4)
      expect {
        blueprint.update(name: name)
      }.to change { blueprint.reload.name }.to(name)
    end

    it "deletes the blueprint" do
      expect {
        blueprint.destroy
      }.to change { blueprint.reload }.to(nil)
    end

    it "boots an environment from a blueprint" do
      new_environment = create_environment(account: account, app: app, environment: {name: SecureRandom.hex(5)}, boot: false)

      expect {
        new_environment.boot("blueprint_id" => blueprint.id)
      }.to change { new_environment.servers.count }.to(5)
    end
  end
end

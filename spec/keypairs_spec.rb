require 'spec_helper'

describe 'as a user' do
  let(:client) { create_client }

  it "should create a keypair" do
    name    = SecureRandom.hex(6)
    ssh_key = SSHKey.generate

    keypair = client.keypairs.create(name: name, public_key: ssh_key.ssh_public_key)

    expect(keypair.application).to be_nil
    expect(keypair.identity).not_to be_nil
    expect(keypair.fingerprint).to be

    expect(keypair.name).to        eq(name)
    expect(keypair.public_key).to  eq(ssh_key.ssh_public_key)
    expect(keypair.user).to        eq(client.users.current)
  end

  context "with a keypair" do
    let!(:account)     { create_account(client: client) }
    let!(:environment) { account.environments.create(name: SecureRandom.hex(6)) }
    let!(:keypair)     { client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key) }

    it "should deploy to an environment" do
      keypair_deployment = keypair.deploy(environment)

      expect(keypair_deployment.identity).not_to be_nil
      expect(keypair_deployment.keypair).to eq(keypair)
      expect(keypair_deployment.environment).to eq(environment)
    end

    it "should show" do
      reloaded = client.keypairs.get(keypair.identity)

      expect(reloaded.attributes).to eq(keypair.attributes)
    end

    context "with many keypairs" do
      let!(:other_a) { client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key) }
      let!(:other_b) { client.keypairs.create(name: SecureRandom.hex(6), public_key: SSHKey.generate.ssh_public_key) }

      it "should list a user's keypairs" do
        expect(client.users.current.keypairs.all).to match_array([keypair, other_a, other_b])
      end

      it "should search keypairs by name" do
        expect(client.keypairs.all(name: other_a.name)).to match_array([other_a])
      end

      it "should search keypairs by fingerprint" do
        expect(client.keypairs.all(fingerprint: other_b.fingerprint)).to match_array([other_b])
      end
    end
  end
end

require 'spec_helper'

describe 'applications' do
  let(:client)        { create_client }

  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }

  let(:app_name)     { SecureRandom.hex(12) }
  let(:repository)   { "#{Faker::Name.first_name}@#{Faker::Internet.domain_name}:#{app_name}/#{app_name}.git" }

  it "should create an application" do
    application = account.applications.create!(name: app_name, type: "rails3", language: "ruby", repository: repository)

    expect(application.id).not_to be_nil
    expect(application.name).to eq(app_name)
    expect(application.type).to eq("rails3")
    expect(application.language).to eq("ruby")
    expect(application.repository).to eq(repository)
  end

  it "should create a deploy keypair when creating an application" do
    expect {
      account.applications.create!(name: app_name, type: "rails3", repository: repository)
    }.to change { client.keypairs.count }.by(1)
  end

  it "should list an application's keypairs" do
    client.keypairs.create(name: "rando", public_key: SSHKey.generate.ssh_public_key) # an existing keypair

    application = account.applications.create!(name: app_name, type: "rails3", repository: repository)

    keypair = application.keypairs.one
    expect(keypair.public_key).to be
  end

  it "should search for application by type" do
    application =  client.applications.create!(name: SecureRandom.hex(12), type: "rails3", repository: repository, account: account)
    client.applications.create!(name: SecureRandom.hex(3), type: "rails2", repository: repository, account: account)

    expect(client.applications.all(type: "rails3").size).to eq(1)
    expect(client.applications.first(type: "rails3")).to eq(application)
  end

  it "should search for application by repository" do
    other_repository = "#{Faker::Name.first_name}@#{Faker::Internet.domain_name}:#{Faker::Name.first_name}/#{Faker::Name.last_name}.git"

    application =  client.applications.create!(name: SecureRandom.hex(12), type: "rails3", repository: repository, account: account)
    client.applications.create!(name: app_name, type: "rails3", repository: other_repository, account: account)

    expect(client.applications.all(repository: repository).size).to eq(1)
    expect(client.applications.first(repository: repository)).to eq(application)
  end
end

require 'spec_helper'

describe 'as a user' do
  let(:client) { create_client }
  let(:location) { 'us-east-1' }
  let!(:account) { create_account(client: client) }

  it 'returns a valid docker registry credentials' do
    credentials = account.retrieve_docker_registry_credentials(location)

    expect(credentials.username).to be
    expect(credentials.password).to be
    expect(credentials.registry_endpoint).to match(/#{location}/)
    expect(credentials.expires_at).to be > (Time.now + 6 * 3600).to_i
  end
end

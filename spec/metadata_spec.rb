require 'spec_helper'

describe 'as a client' do
  let!(:client) { create_client }

  it "should display metadata information" do
    environment = Ey::Core::Client.mocking? ? "mock" : "development"

    expect(client.metadata.environment).to eq(environment)
  end
end

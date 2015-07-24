require 'spec_helper'

describe 'as a client' do
  let!(:client) { create_hmac_client }

  it "should display services information" do
    expect(client.services.all).to contain_exactly(client.metadata)
  end
end

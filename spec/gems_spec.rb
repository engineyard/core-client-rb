require 'spec_helper'

describe "gems" do
  let!(:client) { create_client }

  it "finds a gem" do
    gem = client.gems.get("ey-core")
    expect(gem.current_version).to eq(Ey::Core::VERSION)
    expect(gem.name).to eq("ey-core")
  end
end

require 'spec_helper'

describe "client" do
  it "recognizes the config_file parameter" do
    tempfile = Tempfile.new('ey-core')
    token    = SecureRandom.hex(20)
    tempfile.write <<-EOF
---
'http://api-development.localdev.engineyard.com:9292/': #{token}
    EOF
    tempfile.rewind

    client = Ey::Core::Client.new(config_file: tempfile)
    expect(client.instance_variable_get(:@token)).to eq(token)
  end
end

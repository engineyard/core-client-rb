require 'spec_helper'

describe "#upload_file" do
  it "should upload a multipart_file", :real_only do
    requests = []
    canary = lambda { |env| requests << Rack::Request.new(env); [200, {}, []] }
    client = Ey::Core::Client.new(adapter: [:rack, canary], token: "blah")

    begin
      file = Tempfile.new('foo')
      file.write("bar")
      file.close

      client.upload_file(:file => file.path)
    ensure
      file.close
      file.unlink   # deletes the temp file
    end

    request = requests.first

    expect(request.content_type).to eq("multipart/form-data")
    expect(request.body.read).to eq("bar")
  end
end

require 'spec_helper'

describe 'application_archives' do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:application) { account.applications.create!(name: "hello_servlet", type: "java") }

  it "should create an application archive" do
    archive = application.archives.create!(filename: "helloservlet.war")

    # FIXME: archive.application.should == application
    expect(archive.filename).to eq("helloservlet.war")
    expect(archive.upload_successful).to eq(false)
    expect(archive.upload_url).to be
  end

  context "with an archive", :mock_only do # needs uploaded archives to pass
    let!(:archive) { application.archives.create!(filename: "helloservlet.war") }

    it "should upload, mark that it was successful, and download" do
      archive.upload(body: "enterprise")

      expect(archive.upload_successful).to eq(true)

      expect(archive.download.body).to eq("enterprise")
    end

    context "with multiple archives" do
      let!(:another_application) { account.applications.create!(name: "hello_bean", type: "java") }
      let!(:another_archive)     { another_application.archives.create!(filename: "helloservlet.war") }

      it "should list based on application" do
        expect(application.archives.all).to match_array([archive])
        expect(another_application.archives.all).to match_array([another_archive])
      end
    end
  end
end

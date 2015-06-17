require 'spec_helper'

describe 'backups' do
  let(:client)       { create_client }
  let!(:account)     { create_account(client: client) }
  let!(:provider)    { create_provider(account: account) }
  let!(:environment) { account.environments.create!(account: account, name: Faker::Name.first_name) }
  let!(:cluster)     { client.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }

  it "should create a backup" do
    metadata = {"database" => "core_production"}
    backup = cluster.backups.create!(metadata: metadata)

    expect(backup.metadata).to eq(metadata)
    expect(backup.created_at).not_to be_nil
    expect(backup.updated_at).not_to be_nil
    expect(backup.finished_at).to be_nil

    expect(backup.cluster).to eq(cluster)
    expect(backup.files).to be_empty
  end

  context "with a backup" do
    let(:backup) { cluster.backups.create! }

    it "should create a file without a mime-type" do
      filename = "thom.gz"
      file = backup.files.create!(filename: filename)
      expect(file.filename).to eq(filename)
      expect(file.mime_type).to match("gzip")
      expect(file.download_url).not_to be_nil
      expect(file.upload_url).not_to be_nil

      expect(file.backup).to eq(backup)
    end

    it "should create a file with a mime-type" do
      filename = "thom.gz"
      mime_type = "application/vanilla-pudding"
      file = backup.files.create!(filename: filename, mime_type: mime_type)

      expect(file.filename).to eq(filename)
      expect(file.mime_type).to eq(mime_type)
      expect(file.download_url).not_to be_nil
      expect(file.upload_url).not_to be_nil

      expect(file.backup).to eq(backup)
    end

    it "should create a file with metadata" do
      filename = "thom.gz"
      metadata = {"ines" => "is awesome"}
      file = backup.files.create!(filename: filename, metadata: metadata)

      expect(file.filename).to eq(filename)
      expect(file.metadata).to eq(metadata)
      expect(file.download_url).not_to be_nil
      expect(file.upload_url).not_to be_nil

      expect(file.backup).to eq(backup)
    end

    context "with a file", :mock_only do
      let(:backup_file) { backup.files.create!(filename: "thom.tar.gz") }

      it "should upload and download a file" do
        backup_file.upload(:body => "thom")

        content = backup_file.download
        expect(content.body).to eq("thom")
      end

      it "should upload and download a multipart file" do
        begin
          file = Tempfile.new('foo')
          file.write("bar")
          file.close

          backup_file.upload(:file => file.path)

          content = backup_file.download
          expect(content.body).to eq("bar")
        ensure
          file.close
          file.unlink   # deletes the temp file
        end
      end
    end

    # @note only servers are allowed to finish backups
    it "should finish!", :mock_only do
      expect(backup.finish!.finished_at).not_to be_nil
    end
  end

  context "with multiple backups" do
    let!(:backup)              { cluster.backups.create! }
    let!(:backup_file)         { backup.files.create!(filename: "thom.tar.gz") }
    let!(:another_cluster)     { environment.clusters.create!(environment: environment, provider: provider, name: Faker::Name.first_name, location: "us-west-2") }
    let!(:another_backup)      { another_cluster.backups.create! }
    let!(:another_backup_file) { another_backup.files.create!(filename: "gordo.tar.gz") }

    it "should be able to list all backups" do
      expect(client.backups.all).to include(backup, another_backup)
    end

    it "should be able to list all backup files" do
      expect(client.backup_files.all).to include(backup_file, another_backup_file)
    end

    it "should be able to list a cluster's backups" do
      expect(cluster.backups.all).to match_array([backup])
      expect(another_cluster.backups.all).to match_array([another_backup])
    end

    it "should be able to list a backup's files" do
      expect(backup.files.all).to match_array([backup_file])
      expect(another_backup.files.all).to match_array([another_backup_file])
    end
  end
end

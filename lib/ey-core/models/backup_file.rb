class Ey::Core::Client::BackupFile < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :download_url
  attribute :upload_url
  attribute :filename
  attribute :mime_type
  attribute :metadata

  has_one :backup

  def save!
    params = {
      "url"         => self.collection.url,
      "backup_file" => {
        "filename"  => self.filename,
        "mime_type" => self.mime_type,
        "metadata"  => self.metadata,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_backup_file(params).body["backup_file"])
    else raise NotImplementedError # update
    end
  end

  def upload(options)
    requires :upload_url

    params = {
      "body"       => options[:body],
      "file"       => options[:file],
      "mime_type"  => options[:mime_type] || self.mime_type,
      "upload_url" => self.upload_url,
    }

    self.connection.upload_file(params)
  end

  def download
    requires :download_url

    params = {
      "url" => self.download_url,
    }

    self.connection.download_file(params)
  end
end

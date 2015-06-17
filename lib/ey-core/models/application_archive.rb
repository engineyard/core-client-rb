class Ey::Core::Client::ApplicationArchive < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :sha256
  attribute :filename
  attribute :upload_successful
  attribute :upload_url
  attribute :url

  has_one :application

  # FIXME: hard coded in core, not exposed via api
  def mime_type
    "text/plain"
  end

  def save!
    if new_record?
      requires :filename
      params = {
        "url" => self.collection.url,
        "application" => self.application_id,
        "application_archive" => {
          "filename" => filename,
          "sha256"   => sha256,
        },
      }
      merge_attributes(self.connection.create_application_archive(params).body["application_archive"])
    else
      params = {
        "id" => id,
        "application" => self.application_id,
        "application_archive" => {
          "upload_successful" => upload_successful,
        }
      }
      merge_attributes(self.connection.update_application_archive(params).body["application_archive"])
    end
  end

  def upload(options)
    requires :upload_url

    params = {
      "body"       => options[:body] || File.read(options[:file]),
      "mime_type"  => self.mime_type,
      "upload_url" => self.upload_url,
    }

    self.connection.upload_file(params)

    self.upload_successful = true
    self.save
  end

  def download
    requires :url

    params = {
      "url" => self.url,
    }

    self.connection.download_file(params)
  end
end

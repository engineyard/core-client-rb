class Ey::Core::Client::Log < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :filename
  attribute :mime_type
  attribute :download_url
  attribute :upload_url

  has_one :component_action

  attr_accessor :file, :component_action_id

  def save!
    if self.file.kind_of?(File)
      body = File.read(self.file)
    else
      body = self.file
    end

    params = {
      "component_action_id" => component_action_id,
      "log" => {
        "file"      => body,
        "filename"  => filename || "log",
        "mime_type" => mime_type,
      }
    }

    merge_attributes(self.connection.create_log(params).body["log"])
  end
end

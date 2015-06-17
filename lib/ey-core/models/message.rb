class Ey::Core::Client::Message < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :message

  attr_accessor :request_id

  def save!
    params = {
      "message" => self.message,
      "url"     => self.collection.url,
    }

    if self.request_id
      params["url"] = self.connection.url_for("/requests/#{self.request_id}/messages")
    end

    if new_record?
      message = self.collection.new(self.connection.create_message(params).body["message"])
      merge_attributes(message.attributes)
    else raise NotImplementedError
    end
  end
end

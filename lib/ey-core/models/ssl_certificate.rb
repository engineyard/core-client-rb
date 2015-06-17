class Ey::Core::Client::SslCertificate < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time

  attribute :name
  attribute :public_certificate
  attribute :private_key
  attribute :certificate_chain
  attribute :self_signed

  has_one :account

  attr_accessor :self_sign

  def save!
    params = {
      "url"             => self.collection.url,
      "account"         => self.account_id,
      "ssl_certificate" => {
        "name"               => self.name,
        "public_certificate" => self.public_certificate,
        "private_key"        => self.private_key,
        "certificate_chain"  => self.certificate_chain,
      }
    }

    params["ssl_certificate"].merge!("self_sign" => self.self_sign.nil? ? self.self_signed : self.self_sign) if new_record?

    if new_record?
      connection.requests.new(self.connection.create_ssl_certificate(params).body["request"])
    else
      params["id"] = self.id
      self.connection.update_ssl_certificate(params).body["request"]
    end
  end

  def destroy!
    self.connection.destroy_ssl_certificate("id" => self.id)
  end
end

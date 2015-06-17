class Ey::Core::Client::Keypair < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :fingerprint
  attribute :public_key

  has_one :user
  has_one :application

  def deploy(environment)
    connection.keypair_deployments.create(keypair: self, environment: environment)
  end

  def destroy!
    connection.requests.new(self.connection.destroy_keypair("id" => self.id).body["request"])
  end

  def save!
    requires :name, :public_key

    params = {
      "url"     => self.collection.url,
      "user"    => self.user_id,
      "keypair" => {
        "name"       => self.name,
        "public_key" => self.public_key,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_keypair(params).body["keypair"])
    else raise NotImplementedError # update
    end
  end
end

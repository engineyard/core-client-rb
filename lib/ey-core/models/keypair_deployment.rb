class Ey::Core::Client::KeypairDeployment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  has_one :keypair
  has_one :target, resource: :environment, collection: :environments

  def save!
    requires :keypair, :environment

    params = {
      "url"         => self.collection.url,
      "keypair"     => self.keypair.identity,
      "environment" => self.environment.identity,
    }

    if new_record?
      merge_attributes(self.connection.create_keypair_deployment(params).body["keypair_deployment"])
    else raise NotImplementedError  #  update
    end
  end

  alias environment= target=
  alias environment target
end

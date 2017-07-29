class Ey::Core::Client::Application < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :language
  attribute :name
  attribute :repository
  attribute :type

  has_one :account

  has_many :archives, key: :application_archives
  has_many :keypairs
  has_many :environment_variables

  def save!
    params = {
      "url"         => self.collection.url,
      "account"     => self.account_id,
      "application" => {
        "name"       => self.name,
        "type"       => self.type,
        "repository" => self.repository,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_application(params).body["application"])
    else raise NotImplementedError # update
    end
  end
end

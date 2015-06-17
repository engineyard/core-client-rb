class Ey::Core::Client::Provider < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :cancelled_at, type: :time
  attribute :created_at,   type: :time
  attribute :credentials
  attribute :provisioned_id
  attribute :shared,       type: :boolean
  attribute :type
  attribute :updated_at,   type: :time

  has_one :account

  has_many :provider_locations
  has_many :servers
  has_many :storages
  has_many :untracked_servers

  def possible_locations(provider_type = self.type)
    self.connection.get_possible_provider_locations(provider_type).body["locations"].map { |l| l["id"] }
  end

  def database_server_snapshots
    connection.database_server_snapshots.load(connection.get_database_server_snapshots("provider" => self.id).body["database_server_snapshots"])
  end

  def discover_database_server_snapshots
    connection.requests.new(connection.discover_database_server_snapshots("provider" => self.id).body["request"])
  end

  # @return [Ey::Core::Client::Account]
  def account
    self.connection.accounts.new(self.connection.get_account("url" => self.account_url).body["account"])
  end

  def destroy!
    connection.requests.new(self.connection.destroy_provider(self.id).body["request"])
  end

  def save
    params = {
      "url"      => self.collection.url,
      "account"  => self.account_id,
      "provider" => {
        "credentials"    => self.credentials,
        "provisioned_id" => self.provisioned_id,
        "type"           => self.type,
      },
    }
    if new_record?
      connection.requests.new(self.connection.create_provider(params).body["request"])
    else raise NotImplementedError # update
    end
  end

  alias save! save
end

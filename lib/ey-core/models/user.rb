class Ey::Core::Client::User < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :email
  attribute :staff
  attribute :deleted_at

  has_many :accounts
  has_many :keypairs

  attr_accessor :password

  def self.api_name
    "User"
  end

  def save!
    requires :name, :email

    params = {
      "name"  => self.name,
      "email" => self.email,
      "password" => self.password,
    }

    merge_attributes(self.connection.create_user("user" => params).body["user"])
  end

  def destroy!
    self.connection.destroy_user("id" => self.id) && true
  end
end

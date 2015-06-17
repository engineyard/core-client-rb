class Ey::Core::Client::Signup < Ey::Core::Model
  extend Ey::Core::Associations

  attr_accessor :name, :email, :password, :account_name, :signup_via, :account

  has_one :account
  has_one :user

  def save!

    params = {
      "user" => {
        "name"     => self.name,
        "email"    => self.email,
        "password" => self.password,
      },
      "account" => {
        "name" => self.account_name,
      }
    }

    if self.signup_via
      params["account"]["signup_via"] = self.signup_via
    end

    merge_attributes(self.connection.create_signup(params).body["signup"])
  end
end

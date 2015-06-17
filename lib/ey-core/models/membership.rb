class Ey::Core::Client::Membership < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :role
  attribute :email

  attribute :created_at
  attribute :deleted_at
  attribute :updated_at

  has_one :account
  has_one :user
  has_one :requester

  def accept!
    params = {
      "membership" => {
        "accepted" => true
      }
    }
    params["id"] = self.id
    merge_attributes(self.connection.update_membership(params).body["membership"])
  end

  def save!
    if new_record?
      params = {
        "membership" => {
          "account"      => self.account.id,
          "user"         => self.user.id,
          "role"         => self.role,
        }
      }
      merge_attributes(self.connection.create_membership(params).body["membership"])
    else
      raise "Updating memberships is not yet supported"
    end
  end

end

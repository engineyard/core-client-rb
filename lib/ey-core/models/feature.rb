class Ey::Core::Client::Feature < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :privacy
  attribute :description

  has_one :account

  def enable!(account)
    params = {
      "account" => account.id,
      "feature" => {
        "id" => self.id,
      }
    }

    self.connection.enable_feature(params)
  end

  def disable!(account)
    params = {
      "account" => account.id,
      "feature" => {
        "id" => self.id
      }
    }

    self.connection.disable_feature(params)
  end
end

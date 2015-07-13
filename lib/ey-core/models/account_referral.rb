class Ey::Core::Client::AccountReferral < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  has_one :referred, collection: "accounts", resource: "account"
  has_one :referrer, collection: "accounts", resource: "account"
end

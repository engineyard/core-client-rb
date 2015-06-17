class Ey::Core::Client::Contact < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :title
  attribute :email
  attribute :phone_number
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :deleted_at, type: :time

end

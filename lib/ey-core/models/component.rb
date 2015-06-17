class Ey::Core::Client::Component < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :uri
  attribute :name

end

class Ey::Core::Client::Service < Cistern::Model

  identity :name

  attribute :now, type: :time
  attribute :environment
  attribute :revision
  attribute :version

end

class Ey::Core::Client::Metadata < Cistern::Singular

  attribute :now, type: :time
  attribute :environment
  attribute :revision
  attribute :version

  def singular_request
    :get_metadata
  end

  def fetch_attributes
    connection.send(self.singular_request).body
  end
end

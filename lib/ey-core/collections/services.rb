class Ey::Core::Client::Services < Cistern::Collection

  model Ey::Core::Client::Service

  def all(options={})
    connection.get_metadata.body.map { |name, attr|
      new(attr.merge("name" => name))
    }
  end

  def get(name)
    self.all.find { |s| s.name == name }
  end
end

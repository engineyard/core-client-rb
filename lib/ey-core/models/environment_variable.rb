class Ey::Core::Client::EnvironmentVariable < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :application_id
  attribute :application_name
  attribute :environment_id
  attribute :environment_name
  attribute :name
  attribute :value
  attribute :sensitive

  has_one :environment
  has_one :application

  def save!
    requires :name, :value
    params = Cistern::Hash.slice(Cistern::Hash.stringify_keys(attributes), "id", "name", "value")

    if new_record?
      requires :application_id, :environment_id
      params.merge!("application_id" => application_id, "environment_id" => environment_id)
      merge_attributes(self.connection.create_environment_variable(params).body["environment_variable"])
    else
      merge_attributes(self.connection.update_environment_variable(params).body["environment_variable"])
    end
  end
end

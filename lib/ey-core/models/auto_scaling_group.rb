class Ey::Core::Client::AutoScalingGroup < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time
  attribute :location_id
  attribute :provisioned_id
  attribute :minimum_size
  attribute :maximum_size
  attribute :desired_capacity

  has_many :auto_scaling_policies

  has_one :environment

  def destroy
    connection.requests.new(connection.destroy_auto_scaling_group("id" => self.identity).body["request"])
  end

  def save!
    if new_record?
      requires :maximum_size, :minimum_size, :environment

      params = {
        "url"                => self.collection.url,
        "environment"        => self.environment_id,
        "auto_scaling_group" => {
          "maximum_size" => self.maximum_size,
          "minimum_size" => self.minimum_size,
        }
      }

      connection.requests.new(connection.create_auto_scaling_group(params).body["request"])
    else
      requires :identity

      params = {
        "id" => self.identity,
        "auto_scaling_group" => {
          "maximum_size" => self.maximum_size,
          "minimum_size" => self.minimum_size,
          "desired_capacity" => self.desired_capacity
        }
      }

      connection.requests.new(connection.update_auto_scaling_group(params).body["request"])
    end
  end
end

class Ey::Core::Client::Slot < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time
  attribute :disabled_at, type: :time
  attribute :disable_requested_at, type: :time
  attribute :flavor
  attribute :image
  attribute :name
  attribute :retired_at, type: :time
  attribute :updated_at, type: :time
  attribute :volumes, type: :array

  has_one :cluster
  has_one :server

  has_many :slot_components, aliases: "components"

  def retire
    return false if new_record?
    params = {
      "id" => id,
      "slot" => {
        "retired" => true
      }
    }

    merge_attributes(self.connection.update_slot(params).body["slot"])
  end

  def disable
    return false if new_record?
    params = {
      "id" => id,
      "slot" => {
        "disabled" => true
      }
    }

    merge_attributes(self.connection.update_slot(params).body["slot"])
  end

  def save!
    raise NotImplementedError, "Cannot create or update a single slot"
=begin
    params = {
      "cluster" => self.cluster_id,
      "url"     => self.collection.url,
      "slot"    => {
        "image"   => self.image,
        "flavor"  => self.flavor,
      },
    }

    if new_record?
      self.connections.slots.load(self.connection.create_slot(params).body["slot"])
    else raise NotImplementedError # update
    end
=end
  end
end

class Ey::Core::Client::AutoScalingAlarm < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :deleted_at,             type: :time
  attribute :created_at,             type: :time
  attribute :updated_at,             type: :time
  attribute :auto_scaling_policy_id, aliases: "auto_scaling_policy", squash: ["id"]
  attribute :name
  attribute :aggregation_type
  attribute :metric_type
  attribute :operand
  attribute :trigger_value,          type: :float
  attribute :number_of_periods,      type: :integer
  attribute :period_length,          type: :integer
  attribute :provisioned_id

  has_one :auto_scaling_policy

  def save!
    requires :auto_scaling_policy_id, :trigger_value, :period_length
    params = {
      "auto_scaling_alarm" => {
        "name" => name,
        "trigger_value" => trigger_value,
        "aggregation_type" => aggregation_type,
        "metric_type" => metric_type,
        "operand" => operand,
        "period_length" => period_length,
        "number_of_periods" => number_of_periods
      },
      "auto_scaling_policy_id"  => auto_scaling_policy_id
    }

    if new_record?
      requires :name
      request_attributes = connection.create_auto_scaling_alarm(params).body["request"]
      connection.requests.new(request_attributes)
    else
      requires :identity
      params.merge!("id" => identity)
      connection.requests.new(connection.update_auto_scaling_alarm(params).body["request"])
    end
  end

  def destroy!
    requires :identity

    connection.requests.new(
      connection.destroy_auto_scaling_alarm("id" => identity).body["request"]
    )
  end
end

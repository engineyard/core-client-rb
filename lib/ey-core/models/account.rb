class Ey::Core::Client::Account < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :cancelled_at, type: :time
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :name
  attribute :support_plan
  attribute :signup_via
  attribute :plan_type

  has_many :applications
  has_many :deis_clusters
  has_many :environments
  has_many :features
  has_many :projects
  has_many :providers
  has_many :addons
  has_many :users
  has_many :owners, key: :users
  has_many :ssl_certificates
  has_many :referrals, key: :account_referrals
  has_many :costs

  has_one :cancellation, assoc_name: 'account_cancellation', collection: :account_cancellations
  has_one :account_trial
  has_one :support_trial

  assoc_writer :owner

  attr_accessor :name_prefix, :plan  #only used on account create

  def cancel!(params = {})
    result = self.connection.cancel_account(self.id, params[:requested_by].id).body
    Ey::Core::Client::AccountCancellation.new(result["cancellation"])
  end

  def save!
    requires_one :name, :name_prefix

    params = {
      "account" => {
        "plan" => self.plan || "standard-20140130",
      },
      "owner" => self.owner_id,
    }

    if self.name
      params["account"]["name"] = self.name
    elsif self.name_prefix
      params["account"]["name_prefix"] = self.name_prefix
    end

    if self.signup_via
      params["account"]["signup_via"] = self.signup_via
    end

    if new_record?
      merge_attributes(self.connection.create_account(params).body["account"])
    else raise NotImplementedError # update
    end
  end
end

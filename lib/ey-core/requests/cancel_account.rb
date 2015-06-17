class Ey::Core::Client
  class Real
    def cancel_account(resource_id, requested_by_id)
      request(
        :method => :post,
        :path   => "account_cancellations",
        :params => {"requested_by_id" => requested_by_id, "account_id" => resource_id},
      )
    end
  end # Real

  class Mock
    def cancel_account(resource_id, requested_by_id)
      self.data[:accounts][resource_id]['cancelled_at'] = Time.now
      account_cancellation_id = self.uuid
      self.data[:accounts][resource_id]['cancellation'] = url_for("/account_cancellations/#{account_cancellation_id}")
      cancellation = {
        "id" => account_cancellation_id,
        "created_at" => Time.now,
        "kind" => "self",
      }
      self.data[:account_cancellations]||= {}
      self.data[:account_cancellations][account_cancellation_id] = cancellation
      response(
        :body    => {"cancellation" => cancellation},
        :status  => 200,
        :headers => {
          "Content-Type" => "application/json; charset=utf8"
        }
      )
    end
  end # Mock
end # Ey::Core::Client

class Ey::Core::Client
  class Real
    def update_slot(params={})
      id = params.delete("id")
      request(
        :method => :put,
        :path   => "/slots/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_slot(params={})
      identity = resource_identity(params)
      slot     = find(:slots, identity)

      slot_params = Cistern::Hash.slice(params["slot"], "name", "retired", "disabled", "flavor", "location", "volumes", "activation")

      if slot_params["retired"]
        slot_params["retired_at"] = Time.now
        slot_params["retired"] = true
      end

      if slot_params.delete("disabled")
        slot_params["disable_requested_at"] = Time.now
      end

      slot.merge! slot_params

      response(
        :body => { "slot" => slot },
        :status => 200
      )
    end
  end
end

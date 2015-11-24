class Ey::Core::Client
  class Real
    def deprovision_environment(options={})
      id = options.delete("id")

      request(
        :method => :put,
        :path   => "/environments/#{id}/deprovision",
      )
    end
  end

  class Mock
    def deprovision_environment(options={})
    end
  end
end

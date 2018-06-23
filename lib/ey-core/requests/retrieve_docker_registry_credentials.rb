class Ey::Core::Client
  class Real
    def retrieve_docker_registry_credentials(account_id, location_id)
      request(
        :path => "/accounts/#{account_id}/docker-registry/#{location_id}/credentials"
      )
    end
  end

  class Mock
    def retrieve_docker_registry_credentials(account_id, location_id)
      response(
        :body => {
          'docker_registry_credentials' => {
            'username'          => 'foo',
            'password'          => 'bar',
            'registry_endpoint' => "https://012345678901.dkr.ecr.#{location_id}.amazonaws.com",
            'expires_at'        => Time.now + 8 * 3600
          }
        }
      )
    end
  end
end

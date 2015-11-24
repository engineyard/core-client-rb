module Ey::Core::Mock
  module Resources
    # Attempt to determine the identity of the resource. Used to make the mock requests DRYer
    #
    # @param params [nil] returns nil
    # @param params [Integer] id of the resource
    # @param params [String] id or url of the resource
    # @param params [Hash] description of resource
    # @option params [String] url url of the resource
    # @option params [String] id id of the resource
    # @return identity of the resource
    def resource_identity(params)
      id = nil
      url = nil

      case params
      when Hash
        id  = params["id"]
        url = params["url"]
      when String
        if params.start_with?(@url)
          url = params
        else
          id = params
        end
      when Integer
        id = params
      when nil
        return
      else
        raise ArgumentError, "Cannot determine resource identity of #{params.inspect}"
      end

      id ||= url && URI.parse(url).path.split("/")[2]

      Integer(id) rescue id
    end

    def find(collection, id_or_url)
      id = resource_identity(id_or_url)

      # polymorphic associations suck
      if collection.is_a?(Array)
        resource = collection.map do |key|
          data = self.data[key][id] || self.data[key][id.to_i]
          [key.to_s.tr('_', '-'), data] if data
        end.compact.first
        resource || response(status: 404, body: "Couldn't find #{collection.last} with #{id}")
      else
        self.data[collection][id] || self.data[collection][id.to_i] || response(status: 404, body: "Couldn't find #{collection} with [#{id}]")
      end
    end

    def mock_account_setup(resource_id, resource)
      resource["support_plan"] ||= "standard"
      account_url = url_for("/accounts/#{resource_id}")
      resource.merge!({
        "id"               => resource_id,
        "account_trial"    => "#{account_url}/trial",
        "addons"           => "#{account_url}/addons",
        "addresses"        => "#{account_url}/addressses",
        "applications"     => "#{account_url}/applications",
        "cancelled_at"     => nil,
        "costs"            => "#{account_url}/costs",
        "created_at"       => Time.now.to_s,
        "deis_clusters"    => "#{account_url}/deis-clusters",
        "environments"     => "#{account_url}/environments",
        "features"         => "#{account_url}/features",
        "memberships"      => "#{account_url}/memberships",
        "notes"            => "#{account_url}/notes",
        "owners"           => "#{account_url}/owners",
        "providers"        => "#{account_url}/providers",
        "referrals"        => "#{account_url}/referrals",
        "requests"         => "#{account_url}/requests",
        "resource_url"     => account_url,
        "ssl_certificates" => "#{account_url}/ssl-certificates",
        "support_trial"    => nil,
        "updated_at"       => Time.now.to_s,
        "users"            => "#{account_url}/users",
      })
      resource
    end

    def mock_ssh_key
      {
        public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC05RVR8BF6gm1oevz+y34AY84OJ3JRSK8sGQycW1Ita7PV8H1b/i5zGWUFjhmR4tuQFjtIku9duZzxKES0bHGVng6PbJeUoJVflYf8rXQzcD4gcF+rYHZGv34N59RH2WYcA+4W4JM8m+hmp/dbXvYjqvf5ykOcETkwUcCfCsAD9tk2GqQQpu8z991Lwu36UHN2I8gcuPy+hR1PokbBxSBT+46MbZFomvA7onjqDcvkXIgZ+GyW12yeKMaF8+zvOT1dDxTnzjvWB7zffCDaNfMW7HkdhvlGAKUxk3CdEVO6peQy4a0E5AdElZDEoCvxpKxKZHXfA6penIysk6p/bEBx".freeze,
        private_key: "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAtOUVUfAReoJtaHr8/st+AGPODidyUUivLBkMnFtSLWuz1fB9\nW/4ucxllBY4ZkeLbkBY7SJLvXbmc8ShEtGxxlZ4Oj2yXlKCVX5WH/K10M3A+IHBf\nq2B2Rr9+DefUR9lmHAPuFuCTPJvoZqf3W172I6r3+cpDnBE5MFHAnwrAA/bZNhqk\nEKbvM/fdS8Lt+lBzdiPIHLj8voUdT6JGwcUgU/uOjG2RaJrwO6J46g3L5FyIGfhs\nltdsnijGhfPs7zk9XQ8U58471ge833wg2jXzFux5HYb5RgClMZNwnRFTuqXkMuGt\nBOQHRJWQxKAr8aSsSmR13wOqXpyMrJOqf2xAcQIDAQABAoIBAACyxbNMRvT/HecC\nWomtRW5A9GGvm0xfCHYWHqtX2uhb+xS/WeyJ/anqFi7ATq72fjx/KXltP8lP1yBD\nNIixxnp6YroBBFDJkeoNjLnX/ZPZQhQj+uqRc8NwJ89r7rDcUP2YskmaUlcwjuQe\nj+Dla/PVTCHFux8WHe9m0WSLyRP61U+aCEMX5mFhaiXCZGZjtN8CpNl/drfbQTyF\nZMGI4AuPiwR4uS0DN1o1VKIYxsDB5ZMvYqwthqF2WZE4H84IJvvfFyhX39hF9VDr\nqiTI2BRQoBs5O5zqCY0C2xxpICJmlqrM9DYd/411GwIGFBHXBgp8qJxF0PIxHjPt\naYHvqrECgYEA5YV7iQdKi07Cip99Y6MeyFjvp7oYHsSlrPko5y7VmDdAZlvZQ6KI\nNlJ7Vbl3GHtRYyPgh6WZMGDH+1EnSON0c/7IJk30BScMl5pAPHSy3cr2QWLlC9tE\ngyTzJC2GwSyN8ObSl9Mv71L1+y1SAS9ZuG984Y8r/EJLaiMwDNv8TVUCgYEAycN/\n4DjBGLvt9WfuXAQdKuUHvxp4LJOz1cAU60hucGYAY9/kmOsdfMUL+kh1diijmT35\nrr5zC665zq2FyVOnbUPkwKDnLW1o13rhxZYX9se1CFMUbskxCbc39CJmmyEX4bOm\n2Wwt2cJpfCnv+D+rMxXldQOFf46XkMiDjhusBq0CgYEAnDpkoRweaH5+ux7embCR\npmurDS8FdgQChZ+/cMUXTJnnMwU3+Oqr7tXr76jjYP2no2TrU0mr4RsvZGiT5fA0\n9zOohzIudEdlMdgj+0Kv8XpSbqVjJNPmaaIAAlMe02SBZUWoeQGeMjf1CTiLBhV1\n662vglUS6o0xihhTf51JulUCgYEAtgxVDH6JFIU0/3Hoa1Q28SY4KCF8/1PCNwKa\nnXT8WSRgA73X6HZ0Y8jztr+8ZIHko3d9G0OyUH82HhsJlQ+LCRbyhzBnhuCqcYrp\nvbthIgUt/jXgQNn+CjMsJHcJt71TbA4KZTGr6Uj2ntbENG1WTsDaCgvEX8TMUxHp\nSccEH/0CgYBULXDEqtCv85sAiJlgQ0uUI/LhAG48B/G8xUgZkSI+hId/dfrZuSqs\nJvms2/3P58fb15rE5fWtn9iPwA6wU2jlJg6KEnCawiEfhTZgy8XRhgQm0XK0HAHz\n4EWoM5VwYbdIs+LyuVQK/yNRJlP3gtODs6ADAZyzVyj8H2VBduzn9w==\n-----END RSA PRIVATE KEY-----\n".freeze,
        fingerprint: 16.times.map {rand(16**2).to_s(16).rjust(2,'0')}.join(":"), # => "8a:56:9a:b3:90:b1:3e:21:33:8d:a8:ee:61:69:c5:bc"
      }
    end
  end
end

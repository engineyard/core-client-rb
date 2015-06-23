class Ey::Core::Client
  class Real
    def get_request(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :path => "requests/#{id}",
        :url  => url,
      )
    end
  end # Real

  class Mock
    def get_request(params={})
      id = params["id"]

      request = self.find(:requests, id)
      request["callback_url"] = "#{self.url}/requests/#{id}/callback"

      response_hash = if request["finished_at"].nil? # finish a previously unfinished request
                        resource_key, key, resource, resource_url = request.delete("resource")

                        if resource # provisioning
                          if resource.is_a?(Array)
                            resource.each { |res| self.data[resource_key][res["id"]] = res }
                          else
                            resource_url ||= if resource.respond_to?(:call)
                                               resource.call(request)
                                             else
                                               self.data[resource_key][key] = resource
                                               resource.delete("resource_url")
                                             end
                          end
                          request["finished_at"] = Time.now
                          request["resource"] = resource_url
                        else
                          resource = self.data[resource_key].delete(key) # deprovisioning
                          self.data[:deleted][resource_key][key] ||= resource
                        end
                        request
                      elsif request["finished_at"] # already finished
                        request
                      else
                        request.dup.tap do |r|
                          collection, id, resource = r.delete("resource")
                          r["progress"] = resource["progress"] if resource && resource.key?("progress")
                          if resource && self.data[collection] && self.data[collection][id]
                            r["resource_url"] = resource["resource_url"]
                          end
                        end
                      end

      response(
        :body   => {"request" => response_hash},
        :status => 200,
      )
    end
  end # Mock
end

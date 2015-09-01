require 'ey-core/version'

require 'addressable/uri'
require 'cistern'
require 'ey-hmac'
require 'ey-hmac/faraday'
require 'faraday'
require 'faraday_middleware'
require 'mime/types'
require 'sshkey'

require 'date'
require 'forwardable'
require 'logger'
require 'yaml'
require 'securerandom'
require 'json'

Cistern.timeout = 5 * 60 # 5 minutes

module Ey
  module Core

    IP_REGEX = /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(\/(\d|[1-2]\d|3[0-2]))?/

    def self.paging_parameters(params)
      if url = params['url']
        Addressable::URI.parse(url).query_values
      else
        params
      end
    end

    # @fixme find a much better way to do this
    def self.colocated?(location_a, location_b)
      location_a.gsub(/[a-z]$/, "") == location_b.gsub(/[a-z]$/, "")
    end
  end
end

require 'ey-core/associations'
require 'ey-core/collection'
require 'ey-core/logger'
require 'ey-core/model'
require 'ey-core/request'
require 'ey-core/subscribable'
require 'ey-core/response'
require 'ey-core/token_authentication'
require 'ey-core/request_failure'
require 'ey-core/response_cache'
require 'ey-core/memory_cache'

require 'ey-core/mock/helper'
require 'ey-core/mock/params'
require 'ey-core/mock/resources'
require 'ey-core/mock/searching'
require 'ey-core/mock/util'

require 'ey-core/client'

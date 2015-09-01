module Ey::Core::Mock
  module Util
    def normalize_hash(hash)
      JSON.load(JSON.dump(hash))
    end

    def deep_dup(object)
      Marshal.load(Marshal.dump(object))
    end

    def uuid
      SecureRandom.uuid
    end

    def ip_address
      Array.new(4) { rand(256) }.join('.')
    end

    def api_token
      SecureRandom.hex(20)
    end
  end
end

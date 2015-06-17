module Ey::Core::Mock
  module Util
    def normalize_hash(hash)
      JSON.load(JSON.dump(hash))
    end

    def deep_dup(object)
      Marshal.load(Marshal.dump(object))
    end

    def uuid
      [8,4,4,4,12].map{|i| Cistern::Mock.random_hex(i)}.join("-")
    end

    def ip_address
      Array.new(4){rand(256)}.join('.')
    end
  end
end

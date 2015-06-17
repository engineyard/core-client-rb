class Ey::Core::MemoryCache
  def self.cache
    @cache ||= {}
  end

  def self.reset!
    self.cache.clear
  end

  def self.read(key)
    cache[key]
  end

  def self.write(key, value)
    cache[key] = value
  end
end

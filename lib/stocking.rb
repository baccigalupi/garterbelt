module Garterbelt
  def self.cache_hash
    @cache_hash ||= {:default => Moneta::Memory.new}
  end
  
  def self.cache(store = :default)
    c = cache_hash[store]
    raise "Cache #{store.inspect} has not yet been configured" unless c
    c
  end
  
  class << self
    attr_writer :wrap_length
  end
  
  def self.wrap_length
    @wrap_length || 80
  end
end
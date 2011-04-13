module Garterbelt
  class << self
    attr_writer :max_pool_size
  end
  
  def self.max_pool_size
    @max_pool_size ||= 1_000
  end
  
  def self.cache_hash
    @cache_hash ||= {:default => Moneta::Memory.new}
  end
  
  def self.cache(store = :default)
    c = cache_hash[store]
    raise "Cache #{store.inspect} has not yet been configured" unless c
    c
  end
end
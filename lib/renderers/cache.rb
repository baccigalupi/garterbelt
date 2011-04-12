module Garterbelt
  class Cache < Renderer
    include ContentRendering
    
    attr_accessor :key, :cache_output, :view_output
    
    def initialize(opts, &block)
      super
      self.key = opts[:key]
      raise ArgumentError, ":key option required" unless key
      self.content = block if block_given?
      raise_unless_block_content
      self.cache_output = ""
    end
    
    def head
      self.view_output = output
      self.output = cache_output
    end
    
    def foot
      view_output << cache_output
      self.output = view_output
    end
    
    def render_content
      if cached = view.cache_store[key]
        self.output << cached
      else
        super                                 # renders block to the diverted output
        view.cache_store[key] = cache_output  # set the cache
      end
    end
  end
end

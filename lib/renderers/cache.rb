module MarkupLounge
  class Cache < Renderer
    include ContentRendering
    
    attr_accessor :key
    
    def initialize(opts, &block)
      super
      self.key = opts[:key]
      raise ArgumentError, ":key option required" unless key
      self.content = block if block_given?
      raise_unless_block_content
    end
  end
end

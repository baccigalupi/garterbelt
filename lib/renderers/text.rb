module Garterbelt
  class Text < Renderer
    attr_accessor :content, :escape
    
    def initialize(opts)
      super
      raise ArgumentError, ":content option required for #{self.class} initialization" unless opts[:content]
      self.content = opts[:content]
      self.escape = view.escape
    end
    
    def raise_with_block_content
      raise ArgumentError, "#{self.class} does not take block content" if self.content.is_a?(Proc)
    end
    
    def render
      raise_with_block_content
      output << "#{indent}#{escaped_content}\n"
    end
    
    def escaped_content
      escape ? ERB::Util.h(content) : content
    end
  end
end

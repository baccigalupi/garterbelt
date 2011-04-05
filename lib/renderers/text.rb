module MarkupLounge
  class Text < Renderer
    attr_accessor :content
    
    def initialize(opts)
      super
      raise ArgumentError, ":content option required for #{self.class} initialization" unless opts[:content]
      self.content = opts[:content]
    end
    
    def raise_with_block_content
      raise ArgumentError, "#{self.class} does not take block content" if self.content.is_a?(Proc)
    end
    
    def render
      raise_with_block_content
      output << "#{indent}#{escaped_content}\n"
    end
    
    def escaped_content
      escape? ? ERB::Util.h(content) : content
    end
    
    def escape?
      !!view.escape
    end
  end
end

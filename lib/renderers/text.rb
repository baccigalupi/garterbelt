module Garterbelt
  class Text < Renderer
    attr_accessor :content, :escape
    
    def initialize(opts)
      super
      self.content = opts[:content] || ''
      self.escape = view.escape
    end
    
    def raise_with_block_content
      raise ArgumentError, "#{self.class} does not take block content" if self.content.is_a?(Proc)
    end
    
    def render
      raise_with_block_content
      str = template
      output << str
      str
    end
    
    def line_end
      [:pretty, :text].include?(style) ? "\n" : ''
    end
    
    def template
      str = escape ? ERB::Util.h(content) : content
      
      if style == :pretty 
        "#{str.wrap(Garterbelt.wrap_length, :indent => indent)}#{line_end}" 
      else 
        "#{str}#{line_end}"
      end
    end
  end
end

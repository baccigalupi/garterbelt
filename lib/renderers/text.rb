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
    
    def escaped_content
      if escape
        str = ERB::Util.h(content)
        if style == :pretty
          str = str.wrap(Garterbelt.wrap_length, :indent => indent)
        end
        str
      else
        content
      end
    end
    
    def template
      "#{escaped_content}#{line_end}"
    end
  end
end

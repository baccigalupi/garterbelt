module Garterbelt
  class Text < Renderer
    attr_accessor :content
    
    def initialize(opts)
      super
      self.content = opts[:content] || ''
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
          str.wrap(Garterbelt.wrap_length, :indent => indent)
        else
          "#{indent}#{str}"
        end
      else
        str = content.gsub(/\s*\n\s*/, "\n#{indent}")
        "#{indent}#{str}"
      end
    end
    
    def indent
      [:minified, :compact, :text].include?(style) ? '' : super
    end
    
    def line_end
      style == :compact ? '' : super
    end
    
    def template
      "#{escaped_content}#{line_end}"
    end
  end
end

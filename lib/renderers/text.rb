module MarkupLounge
  class Text < Renderer
    attr_accessor :content
    
    def initialize(opts)
      super
      raise ArgumentError, ":content option required for Text initialization" unless opts[:content]
      self.content = opts[:content]
    end
    
    def render
      raise ArgumentError, "Text does not take block content" if self.content.is_a?(Proc)
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

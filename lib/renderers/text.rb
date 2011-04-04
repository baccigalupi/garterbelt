module MarkupLounge
  class Text < Renderer
    attr_accessor :content
    
    def initialize(opts)
      super
      raise ArgumentError, ":content option required for Text initialization" unless opts[:content]
      @indent = opts[:indent]
      self.content = opts[:content]
    end
    
    def indent?
      !!@indent
    end
    
    def render
      raise ArgumentError, "Text does not take block content" if self.content.is_a?(Proc)
      view.level += 1 if indent?
      output << "#{indent}#{escaped_content}\n"
      view.level -= 1 if indent?
      output
    end
    
    def escaped_content
      escape? ? ERB::Util.h(content) : content
    end
    
    def escape?
      !!view.escape
    end
  end
end

module MarkupLounge
  class Tag < ClosedTag
    attr_accessor :content
    
    def initialize(opts, &block)
      super
      if block_given?
        self.content = block
      else
        self.content = opts[:content]
      end
    end
    
    def id(identifier, &block)
      super(identifier)
      self.content = block if block_given?
      self
    end
    
    def c(*classes, &block)
      super(*classes)
      self.content = block if block_given?
      self
    end
    
    def render
      self.output << "#{indent}<#{type}#{rendered_attributes}>\n"
      render_content
      self.output << "#{indent}</#{type}>\n"
      output
    end
    
    def render_content
      view.level += 1
      if content.is_a?(Proc)
        content.call
        self.output << "\n"
      else
        self.output << "#{indent}#{content}\n" if content
      end
      view.level -= 1
    end
  end
end
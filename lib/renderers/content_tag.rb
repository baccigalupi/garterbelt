module MarkupLounge
  class ContentTag < ClosedTag
    include ContentRendering
    
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
    
    def head
      self.output << "#{indent}<#{type}#{rendered_attributes}>\n"
      super
    end
    
    def foot
      super
      self.output << "#{indent}</#{type}>\n"
    end
  end
end
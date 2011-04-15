module Garterbelt
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
    
    def head_template
      style == :text ? '' : "#{indent}<#{type}#{rendered_attributes}>#{style == :pretty ? line_end : ''}"
    end
    
    def head
      self.output << head_template
      super
    end
    
    def foot_template
      style == :text ? '' : "#{indent}</#{type}>#{line_end}"
    end
    
    def foot
      super
      self.output << foot_template
    end
  end
end
module Garterbelt
  class ContentTag < SimpleTag
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
    
    def method_missing(name, *args, &block)
      if block_given?
        self.content = block
        super rescue self
      else
        super
      end
    end
    
    def head_template
      if style == :text 
        ''
      else 
        head_end = if compactize?
          view.render_style = :minimized
          ''
        else
          line_end
        end
        
        "#{indent}<#{type}#{rendered_attributes}>#{head_end}"
      end
    end
    
    def compactize?
      @compactize ||= style == :compact && !content.is_a?(Proc) 
    end
    
    def head
      self.output << head_template
      super
    end
    
    def foot_template
      if style == :text 
        [:p, :ul, :ol, :li].include?(type) ? "\n" : '' 
      else
        foot_dent = compactize? ? '' : indent
        "#{foot_dent}</#{type}>#{line_end}"
      end
    end
    
    def foot
      super
      self.output << foot_template
    end
  end
end
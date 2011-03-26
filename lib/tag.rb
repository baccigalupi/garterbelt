module MarkupLounge
  class Tag
    include RuPol::Swimsuit
    max_pool_size 10000
    
    attr_accessor :type, :level, :attributes, :content, :css_class
    
    def initialize(opts, &block)
      self.type = opts[:type] || raise(ArgumentError, ":type required in initialization options")
      self.level = opts[:level] || 0
      self.attributes = opts[:attributes] || {}
      
      css_class = attributes.delete(:class)
      self.css_class = if css_class
        css_class.is_a?(Array) ? css_class : [css_class]
      else
        []
      end
      
      self.content = block_given? ? block : opts[:content]
    end
    
    # Convenience method chaining ---------------------------
    
    def id(identifier, &block)
      raise ArgumentError, "Id must be a String or Symbol" unless [String, Symbol].include?(identifier.class)
      self.attributes[:id] = identifier
      self.content = block if block_given?
      self
    end
    
    def c(*args, &block)
      self.css_class += args
      self.content = block if block_given?
      self
    end
    
    alias :* :c
    
    # Rendering -----------------------------------------------
    
    def indent
      ' '*level*2
    end
    
    def rendered_attributes
      str = " "
      str << "class='#{css_class.join(' ')}'" unless css_class.empty?
      attributes.each do |key, value|
        str << " #{key}='#{value}'"
      end
      str
    end
    
    def rendered_content
      content
    end
    
    def render
      "#{indent}<#{type}#{rendered_attributes}>#{rendered_content}</#{type}>\n"
    end
  end
end
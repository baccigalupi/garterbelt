module MarkupLounge
  class ClosedTag
    include RuPol::Swimsuit
    max_pool_size 10000
    
    attr_accessor :type, :view, :attributes, :css_class, :output
    
    def initialize(opts, &block)
      self.type = opts[:type] || raise(ArgumentError, ":type required in initialization options")
      self.view = opts[:view] || raise(ArgumentError, ":view required in initialization options")
      self.attributes = opts[:attributes] || {}
      self.output = view.output
      
      css_class = attributes.delete(:class)
      self.css_class = if css_class
        css_class.is_a?(Array) ? css_class : [css_class]
      else
        []
      end
    end
    
    # Convenience method chaining ---------------------------
    
    def id(identifier)
      raise ArgumentError, "Id must be a String or Symbol" unless [String, Symbol].include?(identifier.class)
      self.attributes[:id] = identifier
      self
    end
    
    def c(*args)
      self.css_class += args
      self
    end
    
    alias :* :c
    
    # Rendering -----------------------------------------------
    
    def level 
      view.level
    end
    
    def indent
      ' '*level*2
    end
    
    def rendered_attributes
      str = ""
      str << " class='#{css_class.join(' ')}'" unless css_class.empty?
      attributes.each do |key, value|
        str << " #{key}='#{value}'"
      end
      str
    end
    
    def render
      str = "#{indent}<#{type}#{rendered_attributes}>\n"
      self.output << str
      str
    end
  end
end
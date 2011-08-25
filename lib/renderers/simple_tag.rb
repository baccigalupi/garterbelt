module Garterbelt
  class SimpleTag < Renderer
    attr_accessor :type, :attributes, :css_class
    
    def initialize(opts)
      super
      self.type = opts[:type] || raise(ArgumentError, ":type required in initialization options")
      self.attributes = opts[:attributes] || {}
      
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
    
    # Rendering -----------------------------------------------
    
    def rendered_attributes
      str = ""
      str << " class=\"#{css_class.join(' ')}\"" unless css_class.empty?
      keys = attributes.keys.sort{|a, b| a.to_s <=> b.to_s}
      keys.each do |key|
        value = attributes[key]
        if value
          value = value.to_s.gsub('"', '\'')
          str << " #{key}=\"#{value}\""
        end
      end
      str
    end
    
    def template
      if style == :text 
        type == :br ? "\n" : ""
      else 
        "#{indent}<#{type}#{rendered_attributes}>#{line_end}"
      end
    end
    
    def render
      str = template
      self.output << str
      str
    end
    
    def method_missing(name, *args, &block)
      super if args.size > 0 || block_given?
      if name.to_s.match(/(.+)!/)
        id($1)
      else
        c(name)
      end
    end
  end
end
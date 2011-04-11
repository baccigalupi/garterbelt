module MarkupLounge
  class View
    include RuPol::Swimsuit
    
    attr_accessor :output, :buffer, :level, :escape
    
    def initialize(opts={})
      self.buffer = []
      self.level = opts.delete(:level) || 0
      self.output = ""
      self.escape = true
      
      params = self.class.default_variables.merge(opts)
      keys = params.keys
      
      unless ((self.class.required || []) - keys).empty?
        raise ArgumentError, "#{(self.class.required - keys).inspect} required as an initialization option"
      end
      
      if self.class.selective_require && keys != self.class.required
        raise ArgumentError, "Allowed initalization options are only #{self.class.required.inspect}"
      end
      
      params.each do |key, value|
        self.class.add_accssor(key) unless respond_to?(key)
        send("#{key}=", value)
      end
    end
    
    # VARIABLE ACCESS -----------------------------
    class << self
      attr_accessor :required, :selective_require
    end
    
    def self.add_accssor key
      key = key.to_s
      return if accessories.include?(key)
      if instance_methods.include?(key)
        raise ArgumentError, ":#{key} cannot be a required variable because it maps to an existing method"
      end
      
      accessories << key.to_s
      attr_accessor key
    end
    
    def self.accessories
      @accessories ||= superclass? ? superclass.accessories.dup : []
    end
    
    def self.superclass?
      @superclassed ||= superclass.respond_to?( :required )
    end
    
    def self.super_required
      superclass? ? superclass.required || [] : []
    end 
    
    def self.default_variables
      @default_variables ||= superclass? ? superclass.default_variables.dup : Hash.new
    end  
    
    def self.requires *args
      if args.last.is_a?(Hash) 
        self.default_variables.merge!(args.pop) 
        args += default_variables.keys.map{ |x| x.to_sym }
      end 
      
      args = super_required + args  
      self.required = args.uniq
      build_accessors
      required
    end
        
    def self.requires_only(*args)
      self.selective_require = true
      requires(*args)
    end
    
    class << self
      alias :needs :requires
      alias :needs_only :requires_only
    end
    
    def self.build_accessors
      required.each do |m|
        add_accssor m
      end
    end
    
    # TAG HELPERS -----------------------
    
    def tag(type, *args, &block)
      tag = ContentTag.new(parse_tag_arguments(type, args), &block)
      buffer << tag
      tag
    end
    
    def closed_tag(type, *args)
      tag = ClosedTag.new(parse_tag_arguments(type, args))
      buffer << tag
      tag
    end
    
    def non_escape_tag(*args, &block)
      if escape
        self.escape = false
        t = tag(*args, &block)
        self.escape = true
        t
      else
        tag(*args, &block)
      end
    end
    
    def parse_tag_arguments(type, args)
      opts = {:type => type, :view => self}
      if args.size == 2
        opts[:content] = args.shift
        opts[:attributes] = args.first
      else
        if args.first.is_a?(Hash)
          opts[:attributes] = args.first
        else
          opts[:content] = args.first
        end
      end
      opts
    end
    
    def text(content)
      tag = Text.new(:view => self, :content => content)
      buffer << tag
      tag
    end
    alias :h :text
    
    def raw_text(content)
      if escape
        self.escape = false
        t = text(content)
        self.escape = true
        t
      else
        text(content)
      end
    end
    alias :raw :raw_text
    alias :rawtext :raw_text
    
    def comment(content)
      tag = Comment.new(:view => self, :content => content)
      buffer << tag
      tag
    end
    
    CLOSED_TAGS = ['area', 'base', 'br', 'col', 'frame', 'hr', 'img', 'input', 'link', 'meta'] # ?? link, meta others in head
    CONTENT_TAGS = [
      'a', 'abbr', 'acronym', 'address', 
      'b', 'bdo', 'big', 'blockquote', 'body', 'button', 
      'caption', 'center', 'cite', 'colgroup',
      'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em',
      'embed',
      'fieldset', 'form', 'frameset',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html', 'i',
      'iframe', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
      'noframes', 'noscript', 
      'object', 'ol', 'optgroup', 'option', 'p', 'param', 
      'q', 's',
      'samp', 'script', 'select', 'small', 'span', 'strike',
      'strong', 'style', 'sub', 'sup',
      'table', 'tbody', 'td', 'textarea', 'tfoot', 
      'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var'
    ] # ?? i, s, title, var
    NON_ESCAPE_TAGS = ['code', 'pre']
    TAGS = CLOSED_TAGS + CONTENT_TAGS
    
    CONTENT_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          tag(:#{type}, *args, &block)
        end
      RUBY
    end
    
    NON_ESCAPE_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          non_escape_tag(:#{type}, *args, &block)
        end
      RUBY
    end
    
    CLOSED_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args)
          closed_tag(:#{type}, *args)
        end
      RUBY
    end  
    
    # RENDERING -------------------------
    
    def render(content_method = :content)
      self.output = ""
      if content_method == :content
        content
      else
        send(content_method)
      end
      render_buffer
      output
    end
    
    def render_buffer
      array = buffer.dup
      buffer.clear
      array.each do |item|
        if item.respond_to?(:render)
          item.render
          item.recycle
        else
          output << item.to_s
        end
      end
    end
    
    def self.render(opts={})
      content_method = opts[:method]
      view = new
      output = content_method ? view.render(content_method) : view.render
      view.recycle
      output
    end
    
    # CACHING ---------------------------
    
    class << self
      attr_writer :cache_store
    end
    
    attr_writer :cache_store
    
    
    def self.cache_store
      @cache_store ||= :default
    end
    
    def cache_store
      @cache_store ||= self.class.cache_store
    end
    
    def cache
      @cache ||= MarkupLounge.cache(cache_store)
    end
  end
end
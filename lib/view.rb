module Garterbelt
  class View
    include RuPol::Swimsuit
    
    attr_accessor :output, :buffer, :level, :escape
    attr_reader :curator
    
    def initialize(opts={})
      self.buffer = []
      self.level =  (opts.delete(:level) || 0)
      self.output = ""
      self.escape = true
      
      self.curator = opts.delete(:curator) || self
      
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
    
    def curator=(parent_view)
      @curator = parent_view
      if parent_view != self
        self.buffer = parent_view.buffer
        self.level = parent_view.level
        self.output = parent_view.output
        self.escape = parent_view.escape
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
    
    def add_to_buffer(renderer)
      buffer << renderer
      renderer
    end
    
    def tag(type, *args, &block)
      add_to_buffer ContentTag.new(parse_tag_arguments(type, args), &block)
    end
    
    def closed_tag(type, *args)
      add_to_buffer ClosedTag.new(parse_tag_arguments(type, args))
    end
    
    def non_escape_tag(*args, &block)
      if escape
        curator.escape = false
        t = tag(*args, &block)
        curator.escape = true
        t
      else
        tag(*args, &block)
      end
    end
    
    def text(content)
      add_to_buffer Text.new(:view => curator, :content => content)
    end
    
    alias :h :text
    
    def raw_text(content)
      if escape
        curator.escape = false
        t = text(content)
        curator.escape = true
        t
      else
        text(content)
      end
    end
    alias :raw :raw_text
    alias :rawtext :raw_text
    
    def comment(content)
      add_to_buffer Comment.new(:view => curator, :content => content)
    end
    
    def doctype(type=:transitional)
      add_to_buffer Doctype.new(:view => curator, :type => type)
    end
    
    def xml(opts={})
      opts = {:version => 1.0, :encoding => 'utf-8'}.merge(opts)
      add_to_buffer Xml.new(parse_tag_arguments(:xml, [opts]))
    end
    
    def parse_tag_arguments(type, args)
      opts = {:type => type, :view => curator}
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
    
    CLOSED_TAGS = ['area', 'br', 'col', 'frame', 'hr', 'img', 'input']
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
      'samp', 'script', 'select', 'small', 'span',
      'strong', 'style', 'sub', 'sup',
      'table', 'tbody', 'td', 'textarea', 'tfoot', 
      'th', 'thead', 'tr', 'tt', 'u', 'ul', 'var'
    ]
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
      self.output = "" if curator === self
      if content_method == :content
        content
      else
        send(content_method)
      end
      render_buffer
      output
    end
    
    alias :to_s :render
    alias :to_html :render
    
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
    
    def partial(*args, &block)
      if (klass = args.first).is_a?(Class)
        args.shift
        view = klass.new(*args)
      else
        view = args.first
      end
      view.curator = curator
      self.buffer << view
      view
    end
    
    alias :widget :partial
    
    # CACHING ---------------------------
    
    class << self
      attr_writer :cache_store_key, :cache_key_base
    end
    
    attr_writer :cache_store_key, :cache_key_base
    
    
    def self.cache_store_key
      @cache_store_key ||= :default
    end
    
    def cache_store_key
      @cache_store_key ||= self.class.cache_store_key
    end
    
    def cache_store
      @cache ||= Garterbelt.cache(cache_store_key)
    end
    
    def self.cache_key_base
      @cache_key_base ||= self.to_s.underscore
    end
    
    def cache_key_base
      @cache_key_base ||= self.class.cache_key_base
    end
    
    CACHE_DETAIL_DEFAULT = 'default'
    
    def cache_key(detail = CACHE_DETAIL_DEFAULT)
      detail ||= CACHE_DETAIL_DEFAULT
      "#{cache_key_base}_#{detail}"
    end
    
    def cache(key, &block)
      renderer = Cache.new(:view => self, :key => cache_key(key), &block)
      buffer << renderer
      renderer
    end
  end
end
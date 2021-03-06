module Garterbelt
  class View
    attr_accessor :output, :_buffer, :_level, :_escape, :block, :initialization_options, :render_style
    attr_reader :_curator
    
    def initialize(opts={}, &block)
      self.initialization_options =  opts
      self._buffer = []
      self._level =  initialization_options.delete(:_level) || 0
      self.render_style = initialization_options.delete(:style) || :pretty
      self.output = ""
      self._escape = true
      self.block = block if block_given?
      
      self._curator = initialization_options.delete(:_curator) || self
      
      params = self.class.default_variables.merge(opts)
      keys = params.keys
      
      unless (self.class.required - keys).empty?
        raise ArgumentError, "#{(self.class.required - keys).inspect} required as an initialization option"
      end
      
      if self.class.selective_require && keys != self.class.required
        raise ArgumentError, "Allowed initalization options are only #{self.class.required.inspect}"
      end
      
      params.each do |key, value|
        self.class.add_accessor(key) unless respond_to?(key)
        instance_variable_set "@#{key}", value
      end
    end
    
    def _curator=(parent_view)
      @_curator = parent_view
      if parent_view != self
        self._buffer = parent_view._buffer
        self._level = parent_view._level
        self.output = parent_view.output
        self._escape = parent_view._escape
        self.render_style = parent_view.render_style
      end
    end
    
    def curated?
      _curator === self
    end
    
    # VARIABLE ACCESS -----------------------------
    class << self
      attr_writer :required
      attr_accessor :selective_require
    end
    
    def self.required
      @required ||= []
    end
    
    def self.add_accessor key
      key = key.to_sym
      i_methods = instance_methods.first.is_a?(String) ? instance_methods.map{|m| m.to_sym} : instance_methods
      return if (accessories + i_methods).include?(key)
      accessories << key
      attr_accessor key
    end
    
    def self.accessories
      @accessories ||= superclass? ? superclass.accessories.dup : []
    end
    
    def self.superclass?
      @superclassed ||= superclass.respond_to?( :required )
    end
    
    def self.super_required
      superclass? ? superclass.required : []
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
      self.required += args.uniq
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
        add_accessor m
      end
    end
    
    # TAG HELPERS -----------------------
    
    def add_to_buffer(renderer)
      _buffer << renderer
      renderer
    end
    
    def tag(type, *args, &block)
      t = if block_given?
        ContentTag.new(parse_tag_arguments(type, args), &block)
      else
        ContentTag.new(parse_tag_arguments(type, args))
      end
      add_to_buffer t
    end
    
    def simple_tag(type, *args)
      add_to_buffer SimpleTag.new(parse_tag_arguments(type, args))
    end
    
    def non_escape_tag(*args, &block)
      if _escape
        _curator._escape = false
        t = block_given? ? tag(*args, &block) : tag(*args)
        _curator._escape = true
        t
      else
        block_given? ? tag(*args, &block) : tag(*args)
      end
    end
    
    def compact_tag(type, *args, &block)
      args << {} unless args.last.is_a?(Hash)
      args.last[:render_style] = :compact
        
      if block_given?
        tag(type, *args, &block)
      else
        tag(type, *args)
      end
    end
    
    def text(content)
      add_to_buffer Text.new(:view => _curator, :content => content)
    end
    
    alias :h :text
    
    def raw_text(content)
      if _escape
        _curator._escape = false
        t = text(content)
        _curator._escape = true
        t
      else
        text(content)
      end
    end
    alias :raw :raw_text
    alias :rawtext :raw_text
    
    def comment_tag(content)
      add_to_buffer Comment.new(:view => _curator, :content => content)
    end
    
    def doctype(type=:transitional)
      add_to_buffer Doctype.new(:view => _curator, :type => type)
    end
    
    def xml(opts={})
      opts = {:version => 1.0, :encoding => 'utf-8'}.merge(opts)
      add_to_buffer Xml.new(parse_tag_arguments(:xml, [opts]))
    end
    
    def parse_tag_arguments(type, args)
      opts = {:type => type, :view => _curator}
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
      opts[:render_style] = opts[:attributes].delete(:render_style) if opts[:attributes] && opts[:attributes][:render_style]
      opts
    end
    
    CONTENT_TAGS = [
      'abbr', 'acronym', 'address', 
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
      'samp', 'select', 'small', 'span',
      'strong', 'sub', 'sup',
      'table', 'tbody', 'td', 'tfoot', 
      'th', 'thead', 'tr', 'tt', 'u', 'ul', 'var'
    ]
    CONTENT_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          block_given? ? tag(:#{type}, *args, &block) : tag(:#{type}, *args)
        end
      RUBY
    end
    
    NON_ESCAPE_TAGS = ['code', 'pre', 'script', 'style']
    NON_ESCAPE_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          block_given? ? non_escape_tag(:#{type}, *args, &block) : non_escape_tag(:#{type}, *args)
        end
      RUBY
    end
    
    SIMPLE_TAGS = ['area', 'br', 'col', 'frame', 'hr', 'img', 'input']
    SIMPLE_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args)
          simple_tag(:#{type}, *args)
        end
      RUBY
    end  
    
    HEAD_TAGS = ['_base', '_meta', '_link']
    HEAD_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args)
          simple_tag(:#{type}, *args)
        end
      RUBY
    end
    
    COMPACTED_TAGSS = ['textarea', 'a']
    COMPACTED_TAGSS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          block_given? ? compact_tag(:#{type}, *args, &block) : compact_tag(:#{type}, *args)
        end
      RUBY
    end
    
    def page_title(*args, &block)
      block_given? ? tag(:title, *args, &block) : tag(:title, *args)
    end
    
    def stylesheet_link(path)
      _link(:rel => "stylesheet", 'type' => "text/css", :href => "#{path}.css")
    end
    
    def javascript_link(path)
      script(:src => "#{path}.js", 'type' => "text/javascript")
    end
    
    # RENDERING -------------------------
    
    def content
      raise NotImplementedError, "Implement #content in #{self.class}!"
    end
    
    class << self
      attr_writer :default_render_style, :default_content_method
    end
    
    def self.default_render_style
      @default_render_style ||= :pretty
    end
    
    def self.default_content_method
      @default_content_method ||= :content
    end
    
    def render(*args)
      if args.first.is_a?(Hash)
        initialization_options = args.shift
        content_method = initialization_options[:method]
      else
        content_method = args.shift
        initialization_options = args.shift || {}
      end
      
      content_method ||= self.class.default_content_method
      self.render_style = initialization_options[:style] || self.class.default_render_style
      
      self.output = "" if curated?
      
      if block
        send(content_method, &block)
      else
        send(content_method)
      end
      
      render_buffer
      output
    end
    
    alias :to_s :render
    alias :to_html :render
    
    def render_block
      return output unless block
      block.call
      render_buffer
      output
    end
    
    def call_block
      block.call if block
    end
    
    def render_buffer
      array = _buffer.dup
      _buffer.clear
      array.each do |item|
        if item.respond_to?(:render)
          item.render
        else
          output << item.to_s
        end
      end
    end
    
    def self.render(opts={}, &block)
      content_method = opts.delete(:method)
      view = block_given? ? new(opts, &block) : new(opts)
      output = content_method ? view.render(content_method) : view.render
      output
    end
    
    def partial(*args, &block)
      view = if (klass = args.first).is_a?(Class)
        args.shift
        partial_opts = args.shift || {}
        available_opts = self.class.default_variables.merge(initialization_options)
        opts = if klass.selective_require
          klass.required.each do |key|
            partial_opts[key] ||= available_opts[key]
          end
          partial_opts
        else
          available_opts.merge(partial_opts)
        end
        klass.new(opts)
      else
        args.first
      end
      view.block = block if block
      view._curator = _curator
      self._buffer << view
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
    
    def cache(key, opts={}, &block)
      opts = opts.merge(:key => cache_key(key), :view => _curator)
      add_to_buffer Cache.new(opts, &block)
    end
  end
end

module MarkupLounge
  class View
    include RuPol::Swimsuit
    
    attr_accessor :output, :buffer, :level, :escape
    
    def initialize(opts={})
      self.buffer = []
      self.level = opts[:level] || 0
      self.output = ""
      self.escape = true
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
      tag = Text.new(:view => self, :indent => true, :content => content)
      buffer << tag
      tag
    end
    
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
  end
end
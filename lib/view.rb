module MarkupLounge
  class View
    include RuPol::Swimsuit
    
    attr_accessor :output, :buffer, :level
    
    def initialize(opts={})
      self.buffer = []
      self.level = opts[:level] || 0
      self.output = ""
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
    
    CLOSED_TAGS = ['area', 'base', 'br', 'col', 'frame', 'hr', 'img', 'input', 'link', 'meta'] # ?? link, meta others in head
    CONTENT_TAGS = [
      'a', 'abbr', 'acronym', 'address', 
      'b', 'bdo', 'big', 'blockquote', 'body', 'button', 
      'caption', 'center', 'cite', 'code', 'colgroup',
      'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em',
      'embed',
      'fieldset', 'form', 'frameset',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html', 'i',
      'iframe', 'ins', 'kbd', 'label', 'legend', 'li', 'map',
      'noframes', 'noscript', 
      'object', 'ol', 'optgroup', 'option', 'p', 'param', 'pre',
      'q', 's',
      'samp', 'script', 'select', 'small', 'span', 'strike',
      'strong', 'style', 'sub', 'sup',
      'table', 'tbody', 'td', 'textarea', 'tfoot', 
      'th', 'thead', 'title', 'tr', 'tt', 'u', 'ul', 'var'
    ] # ?? i, s, title, var
    TAGS = CLOSED_TAGS + CONTENT_TAGS
    
    CONTENT_TAGS.each do |type|
      class_eval <<-RUBY
        def #{type}(*args, &block)
          tag(:#{type}, *args, &block)
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
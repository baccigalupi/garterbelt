module MarkupLounge
  class View
    include RuPol::Swimsuit
    
    CLOSED_TAGS = ['area', 'base', 'br', 'col', 'frame', 'hr', 'img', 'input', 'link', 'meta']
    OPEN_TAGS = [
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
    ]
    TAGS = CLOSED_TAGS + OPEN_TAGS
    
    attr_accessor :output, :buffer, :level
    
    def initialize(opts={})
      self.level = opts[:level] || 0
      self.output = ""
    end
    
    def render(content_method = :content)
      self.output = ""
      if content_method == :content
        content
      else
        send(content_method)
      end
      output
    end
  end
end
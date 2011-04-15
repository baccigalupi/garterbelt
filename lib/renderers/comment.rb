module Garterbelt
  class Comment < Text
    def initialize(opts)
      super
    end
    
    def template
      view.render_style == :text ? "" : "#{indent}<!-- #{content} -->#{line_end}"
    end
    
    def render
      raise_with_block_content
      output << template
    end
  end
end
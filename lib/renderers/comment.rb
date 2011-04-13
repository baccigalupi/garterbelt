module Garterbelt
  class Comment < Text
    def initialize(opts)
      super
    end
    
    def render
      raise_with_block_content
      output << "#{indent}<!-- #{content} -->\n"
    end
  end
end
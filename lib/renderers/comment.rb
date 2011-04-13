module Garterbelt
  class Comment < Text
    max_pool_size Garterbelt.max_pool_size
    
    def initialize(opts)
      super
    end
    
    def render
      raise_with_block_content
      output << "#{indent}<!-- #{content} -->\n"
    end
  end
end
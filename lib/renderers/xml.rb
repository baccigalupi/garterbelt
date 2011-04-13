module Garterbelt
  class Xml < ClosedTag
    max_pool_size Garterbelt.max_pool_size
    
    def template
      "#{indent}<?xml #{rendered_attributes} ?>\n"
    end
  end
end

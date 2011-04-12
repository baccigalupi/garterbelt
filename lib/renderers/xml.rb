module Garterbelt
  class Xml < ClosedTag
    max_pool_size 1000
    
    def template
      "#{indent}<?xml #{rendered_attributes} ?>\n"
    end
  end
end

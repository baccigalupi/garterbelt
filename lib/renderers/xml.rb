module Garterbelt
  class Xml < ClosedTag
    def template
      "#{indent}<?xml #{rendered_attributes} ?>\n"
    end
  end
end

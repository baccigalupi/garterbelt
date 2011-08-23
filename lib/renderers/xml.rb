module Garterbelt
  class Xml < SimpleTag
    def template
      "#{indent}<?xml #{rendered_attributes} ?>\n"
    end
  end
end

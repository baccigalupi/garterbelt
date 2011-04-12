module Garterbelt
  class Page < View
    # CLASS LEVEL CONFIGURATION --------------------------------------
    
    class << self
      attr_writer :doctype, :html_attributes
    end
    
    def self.superclassed?
      superclass.ancestors.include?(Garterbelt::Page)
    end
    
    def self.doctype
      @doctype ||= superclassed? ? superclass.doctype : :transitional
    end
    
    def self.html_attributes
      @html_attributes ||= superclassed? ? superclass.html_attributes : {}
    end
    
    # THE CONTENT ----------------------------------------------------
    
    def body_attributes
      {}
    end
    
    def content
      doctype self.class.doctype
      html( self.class.html_attributes ) do
        tag(:head) do
          head
        end
        
        tag(:body, body_attributes) do
          body
        end
      end
    end
    
    def head
    end
    
    def body
    end
  end
end
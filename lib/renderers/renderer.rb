module Garterbelt
  class Renderer
    attr_accessor :view
    
    def initialize(opts)
      self.view = opts[:view] || raise(ArgumentError, ":view required in initialization options")
    end
    
    # Rendering -----------------------------------------------
    def output
      view.output
    end
    
    def output=(alt_output)
      view.output = alt_output
    end
    
    def level 
      view.level
    end
    
    def indent
      view.render_style == :minified ? "" : ' '*level*2
    end
    
    def line_end
      view.render_style == :minified ?  "" : "\n"
    end
    
    def render
      raise NotImplementedError, "Subclasses must implement #render"
    end
  end
end
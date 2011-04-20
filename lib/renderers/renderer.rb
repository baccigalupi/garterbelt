module Garterbelt
  class Renderer
    attr_accessor :view, :escape
    attr_writer :style
    
    def initialize(opts)
      self.view = opts[:view] || raise(ArgumentError, ":view required in initialization options")
      self.style = opts.delete(:render_style)
      self.escape = view._escape
    end
    
    # Rendering -----------------------------------------------
    def output
      view.output
    end
    
    def output=(alt_output)
      view.output = alt_output
    end
    
    def level 
      view._level
    end
    
    def style
      @style ||= view.render_style
    end
    
    def indent
      style == :minified ? "" : ' '*level*2
    end
    
    def line_end
      style == :minified ?  "" : "\n"
    end
    
    def render
      raise NotImplementedError, "Subclasses must implement #render"
    end
  end
end
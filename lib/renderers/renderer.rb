module Garterbelt
  class Renderer
    include RuPol::Swimsuit
    max_pool_size 10000
    
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
      ' '*level*2
    end
    
    def render
      raise NotImplementedError, "Subclasses must implement #render"
    end
  end
end
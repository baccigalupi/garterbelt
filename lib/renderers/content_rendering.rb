module Garterbelt
  module ContentRendering
    def self.included(base)
      base.class_eval <<-RUBY
        attr_accessor :content, :view_escape, :view_style
        
        include InstanceMethods
      RUBY
    end
    
    module InstanceMethods
      def render
        head
        render_content
        foot
        output
      end

      def head
        self.view_style = view.render_style
        self.view_escape = view._escape
        
        view.render_style = style
        view._escape = escape
        view._level += 1
      end

      def foot
        view.render_style = view_style
        view._escape = view_escape
        view._level -= 1
      end

      def render_content
        if content.is_a?(Proc)
          content.call
        else
          view._buffer << Text.new(:view => view, :content => content) if content
        end
        view.render_buffer
      end
      
      def raise_unless_block_content
        raise ArgumentError, "Block content required" unless self.content && self.content.is_a?(Proc)
      end
    end
  end
end
module MarkupLounge
  module ContentRendering
    def self.included(base)
      base.class_eval <<-RUBY
        attr_accessor :content
        
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
        view.level += 1
      end

      def foot
        view.level -= 1
      end

      def render_content
        if content.is_a?(Proc)
          content.call
        else
          view.buffer << Text.new(:view => view, :content => content) if content
        end
        view.render_buffer
      end
      
      def raise_unless_block_content
        raise ArgumentError, "Block content required" unless self.content && self.content.is_a?(Proc)
      end
    end
  end
end
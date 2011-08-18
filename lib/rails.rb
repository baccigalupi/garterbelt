if defined?(Rails) 
  module Garterbelt
    module Rails
      class TemplateHandler 
        def self.call(template)
          klass = extract_class( template.identifier )
          <<-RUBY 
            ::#{klass}.new(assigns).render
          RUBY
        end

        def self.extract_class(identifier)
          identifier.match(/#{::Rails.root}\/app\/(.*)\.html\.rb/).captures.last.camelize
        end

        def self.reload_templates
          Object.send(:remove_const, :Views) rescue nil
          Dir.glob(::Rails.root.to_s + '/app/views/*').each do |dir|
            make_module dir[/[a-z0-9_]*$/].camelize
            Dir[dir + '**/*.rb'].each do |view_path| 
              eval_view(view_path)
            end  
          end
        end
        
        def self.eval_view(path)
          klass = extract_class( path )
          begin
            require path
            klass.constantize
          rescue
            view = File.read(path)
            view.gsub!(/#{klass}/, "::#{klass}")
            eval view
          end
        end

        def self.make_module(name)
          make_view_module
          begin
            "::Views::#{name}".constantize
          rescue
            eval "module ::Views::#{name}; end"
          end
        end

        def self.make_view_module
          begin 
            'Views'.constantize
          rescue
            eval "module ::Views; end"
          end
        end
      end

      class Railtie < ::Rails::Railtie
        config.to_prepare do
          TemplateHandler.reload_templates
        end
      end
    
      ::ActionView::Template.register_template_handler :rb, TemplateHandler  
    end
  end
end
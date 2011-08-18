# this is some Rails mockyness because 
# require 'rails' when run from rspec causes
# defined?(Rails) == nil, awesomeness!

class Configer
  attr_accessor :events
  
  def initialize
    self.events = []
  end
  
  def to_prepare(&block)
    events << block
  end
end

class Rails
  def self.root
    File.expand_path( File.dirname(__FILE__) + "/integration/rails" ) 
  end
  
  class Railtie
    def self.config
      unless @config
        @config = Configer.new
      end
      @config
    end
  end
end

module ActionView
  class Template
    def self.config
      @config ||= Configer.new
    end
    
    def self.register_template_handler( *arg )
      config.events << "registered template handler #{arg.inspect}"
    end
  end
end


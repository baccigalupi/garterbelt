require 'rubygems'

require File.dirname(__FILE__) + "/performancer"
require 'haml'

class RenderEngineTest < Performancer
  def self.template
    @template ||= File.read(File.dirname(__FILE__) + '/templates/' + file_name )
  end
  
  def self.file_name
    'standard.haml'
  end
  
  def engine
    Haml::Engine
  end
  
  def perform
    engine.new().to_html()
  end
end 
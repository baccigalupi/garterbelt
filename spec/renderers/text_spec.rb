require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::Text do
  before :all do
    @view = MockView.new
  end
  
  describe 'basics' do
    it 'is decends from Renderer' do
      Garterbelt::Text.ancestors.should include Garterbelt::Renderer
    end
    
    it 'has conent' do
      text = Garterbelt::Text.new(:view => @view, :content => "Initializing ...")
      text.content.should == "Initializing ..."
      text.content = "foo"
      text.content.should == "foo"
    end
    
    it 'raises an error when initializing without content' do
      lambda{ Garterbelt::Text.new(:view => @view) }.should raise_error( 
        ArgumentError, ":content option required for Garterbelt::Text initialization" 
      )
    end
    
    it 'inherits its pool size' do
      Garterbelt::Text._pool.max_size.should == 10000
    end
  end
  
  describe 'render' do
    before do
      @view = MockView.new
      @text = Garterbelt::Text.new(:view => @view, :content => 'Render me')
    end
    
    it 'raises an error with block content' do
      @text.content = lambda { puts "foo" }
      lambda{ @text.render }.should raise_error(ArgumentError, "Garterbelt::Text does not take block content")
    end
    
    it 'it adds the content to the output' do
      @text.render
      @view.output.should include "Render me"
    end
    
    it 'indents to the view level' do
      @text.render
      @view.output.should match /^\W{4}Render me\n$/
    end
    
    describe 'escaping' do
      it 'escapes if view is set to escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        text = Garterbelt::Text.new(:view => @view, :content => str)
        text.render.should_not include str
        text.render.should include ERB::Util.html_escape(str)
      end
      
      it 'does not escape if the view is set to not escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        @view.escape = false
        text = Garterbelt::Text.new(:view => @view, :content => str)
        text.render.should include str
      end
    end
  end
end
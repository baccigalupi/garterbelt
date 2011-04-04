require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::Text do
  before :all do
    @view = MockView.new
  end
  
  describe 'basics' do
    it 'is decends from Renderer' do
      MarkupLounge::Text.ancestors.should include MarkupLounge::Renderer
    end
    
    it 'has conent' do
      text = MarkupLounge::Text.new(:view => @view, :content => "Initializing ...")
      text.content.should == "Initializing ..."
      text.content = "foo"
      text.content.should == "foo"
    end
    
    it 'raises an error when initializing without content' do
      lambda{ MarkupLounge::Text.new(:view => @view) }.should raise_error( 
        ArgumentError, ":content option required for Text initialization" 
      )
    end
    
    it 'inherits its pool size' do
      MarkupLounge::Text._pool.max_size.should == 10000
    end
    
    it 'takes an indent option and converts it to #indent?' do
      MarkupLounge::Text.new(:view => @view, :content => 'foo').indent?.should be_false
      MarkupLounge::Text.new(:view => @view, :indent => true, :content => 'foo').indent?.should be_true
    end
  end
  
  
  describe 'render' do
    before do
      @view = MockView.new
      @text = MarkupLounge::Text.new(:view => @view, :content => 'Render me')
    end
    
    it 'raises an error with block content' do
      @text.content = lambda { puts "foo" }
      lambda{ @text.render }.should raise_error(ArgumentError, "Text does not take block content")
    end
    
    it 'it adds the content to the output' do
      @text.render
      @view.output.should include "Render me"
    end
    
    describe 'indentation' do
      it 'indents to the view level by default' do
        @text.render
        @view.output.should match /^\W{4}Render me\n$/
      end
      
      it 'indents one addition level when #indent? is true' do
        text = MarkupLounge::Text.new(:view => @view, :content => 'Indent me more', :indent => true)
        text.render
        @view.output.should match /^\W{6}Indent me more\n$/
      end
    end
    
    describe 'escaping' do
      it 'escapes if view is set to escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        text = MarkupLounge::Text.new(:view => @view, :content => str)
        text.render.should_not include str
        text.render.should include ERB::Util.html_escape(str)
      end
      
      it 'does not escape if the view is set to not escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        @view.escape = false
        text = MarkupLounge::Text.new(:view => @view, :content => str)
        text.render.should include str
      end
    end
  end
end
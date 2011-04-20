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
    
    describe 'escaping' do
      it 'escapes if view is set to escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        text = Garterbelt::Text.new(:view => @view, :content => str)
        text.render.should_not include str
        text.render.should include ERB::Util.html_escape(str)
      end
      
      it 'does not escape if the view is set to not escape' do
        str = "<a href='/foo.com'>Foo it!</a>"
        @view._escape = false
        text = Garterbelt::Text.new(:view => @view, :content => str)
        text.render.should include str
      end
    end
    
    describe 'styles' do
      before do
        @str = "123456789 "*40 # 100 char long
        @tag = Garterbelt::Text.new(:content =>  @str, :view => @view)
        @view.render_style = :pretty
        @pretty = @tag.render
      end
      
      describe ':pretty' do
        it 'indents to the view level' do
          rendered = @tag.render
          @view.output.should include rendered
        end
        
        it 'wraps' do
          @tag = Garterbelt::Text.new(:content => "12345678 "*15, :view => @view) 
          matcher = "12345678 "*7 + "12345678"
          @tag.render.should match /^    #{matcher}\n/ 
        end
        
        it 'ends in a line break' do
          @tag.render.should match  /\n\z/
        end
      end
      
      describe ':minified' do
        before do
          @tag.style = :minified
          @minified = @tag.render
        end
        
        it 'does not have any line break(s)' do
          @minified.should_not match  /\n/
        end
        
        it 'does not have any indentation' do
          @pretty.should match /^\s{4}1/
          @minified.should_not match /^\s{4}a1/
        end
      end
      
      describe ':text' do
        before do
          @tag.style = :text
          @text = @tag.render
        end
        
        it 'should end in a line break' do
          @text.should match /\n\z/
        end
        
        it 'should not wrap' do
          @text.should_not match /\n1/
        end
      end
      
      describe 'compact' do
        before do
          @tag.style = :compact
          @compact = @tag.render
        end
        
        it 'is just the string' do
          @compact.should == @str
        end
      end
      
    end
  end
end
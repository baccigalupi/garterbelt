require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::Comment do
  before :all do
    @view = MockView.new
  end
  
  describe 'basics' do
    it 'is decends from Renderer' do
      Garterbelt::Comment.ancestors.should include Garterbelt::Renderer
    end
    
    it 'has conent' do
      comment = Garterbelt::Comment.new(:view => @view, :content => "Initializing ...")
      comment.content.should == "Initializing ..."
      comment.content = "foo"
      comment.content.should == "foo"
    end
  end
  
  describe 'render' do
    before do
      @view = MockView.new
      @comment = Garterbelt::Comment.new(:view => @view, :content => 'Render me')
    end
    
    describe 'basics' do
      it 'raises an error with block content' do
        @comment.content = lambda { puts "foo" }
        lambda{ @comment.render }.should raise_error(ArgumentError, "Garterbelt::Comment does not take block content")
      end
    
      it 'it adds the content to the output' do
        @comment.render
        @view.output.should include "Render me"
      end
    
      it 'builds the right header tag' do
        @comment.render
        @view.output.should match /<!-- Render me/
      end
    
      it 'builds the right footer tag' do
        @comment.render
        @view.output.should match /Render me -->/
      end
    
      it 'indents to the view level' do
        @comment.render
        @view.output.should match /^\W{4}<!-- Render me/
      end
    
      it 'does not escape the content' do
        @comment.content = "<div>foo</div>"
        @comment.render
        @view.output.should include "<div>foo</div>"
      end
    end
    
    describe 'styles' do
      before do
        @tag = Garterbelt::Comment.new(:view => @view, :content => 'foo')
        @view.render_style = :pretty
        @pretty = @tag.render
        @view.output = ''
      end
      
      describe ':minified' do
        before do
          @tag.style = :minified
          @min = @tag.render
        end
        
        it 'does not end in a line break' do
          @min.should_not match  /\n$/
        end
        
        it 'does not have any indentation' do
          @pretty.should match /^\s{4}</
          @min.should_not match /^\s{4}</
        end
      end
      
      describe ':text' do
        it 'is an empty string' do
          @tag.style = :text
          @tag.render.should == ''
        end
      end
    end
  end
end

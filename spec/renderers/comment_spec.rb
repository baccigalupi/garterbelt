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
    
    it 'raises an error when initializing without content' do
      lambda{ Garterbelt::Comment.new(:view => @view) }.should raise_error( 
        ArgumentError, ":content option required for Garterbelt::Comment initialization" 
      )
    end
  end
  
  describe 'render' do
    before do
      @view = MockView.new
      @comment = Garterbelt::Comment.new(:view => @view, :content => 'Render me')
    end
    
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
end

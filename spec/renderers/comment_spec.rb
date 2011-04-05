require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::Comment do
  before :all do
    @view = MockView.new
  end
  
  describe 'basics' do
    it 'is decends from Renderer' do
      MarkupLounge::Comment.ancestors.should include MarkupLounge::Renderer
    end
    
    it 'has conent' do
      comment = MarkupLounge::Comment.new(:view => @view, :content => "Initializing ...")
      comment.content.should == "Initializing ..."
      comment.content = "foo"
      comment.content.should == "foo"
    end
    
    it 'raises an error when initializing without content' do
      lambda{ MarkupLounge::Comment.new(:view => @view) }.should raise_error( 
        ArgumentError, ":content option required for MarkupLounge::Comment initialization" 
      )
    end
    
    it 'has a smaller pool size' do
      MarkupLounge::Comment._pool.max_size.should == 1000
    end
  end
  
  describe 'render' do
    before do
      @view = MockView.new
      @comment = MarkupLounge::Comment.new(:view => @view, :content => 'Render me')
    end
    
    it 'raises an error with block content' do
      @comment.content = lambda { puts "foo" }
      lambda{ @comment.render }.should raise_error(ArgumentError, "MarkupLounge::Comment does not take block content")
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

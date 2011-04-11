require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View do
  class BasicView < MarkupLounge::View
    def content
    end
  
    def alt_content
    end
  end

  before do
    @view = BasicView.new
  end

  describe 'pooling' do
    it 'includes the swimsuit' do
      BasicView.ancestors.should include( RuPol::Swimsuit )
    end
  end

  describe 'attributes' do
    it 'has a tag buffer' do
      @view.buffer.should == []
      @tag = MarkupLounge::ContentTag.new(:view => @view, :type => :hr)
      @view.buffer << @tag
      @view.buffer.should == [@tag]
    end
    
    describe '#curator (view responsible for displaying the rendered content)' do
      it 'is self by default' do
        @view.curator.should == @view
      end
      
      it 'can be set' do
        @view.curator = BasicView.new
        @view.curator.should_not == @view
      end
      
      it 'can be intialized in' do
        BasicView.new(:curator => @view).curator.should == @view
      end
    end
    
    describe 'output' do
      it 'has an output' do
        @view.output.should == ""
      end
    
      it 'its output is that of the curator if the curator is not self' do
        BasicView.new(:curator => @view).output.should === @view.output
      end
    end

    describe 'escape' do
      it 'has escape set to true by default' do
        @view.escape.should == true
      end
      
      it 'can be set' do
        @view.escape = false
        @view.escape.should == false
        BasicView.new(:escape => false).escape.should == false
      end
    end
    
    describe 'level' do
      it 'is 0 by default' do
        @view.level.should == 0
      end
      
      it 'can be set via initialization' do
        BasicView.new(:level => 42).level.should == 42
      end
    end
  end
end


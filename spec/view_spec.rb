require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MarkupLounge::View do
  class BasicView < MarkupLounge::View
    def content
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
    it 'has an output' do
      @view.output.should == ""
    end
    
    it 'has a tag buffer' do
      @view.buffer.should == nil
      @tag = Tag.new(:view => @view, :type => :hr)
      @view.buffer = @tag
      @view.buffer.should == @tag
    end
  end
  
  describe 'rendering' do
    it 'clears the output on start' do
      @view.output = 'Foo the magic output!'
      @view.render
      @view.output.should_not include 'Foo the magic output!'
    end
    
    describe 'methods' do
      it 'renders the :content method by default' do
        @view.should_receive(:content)
        @view.render
      end
    
      it 'renders an alternate method when requested' do
        @view.should_receive(:foo)
        @view.render(:foo)
      end
    end
    
    it 'returns the output' do
      @view.render.should === @view.output
    end
  end
end
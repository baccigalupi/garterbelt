require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::View do
  class BasicView < Garterbelt::View
    def content
    end
  
    def alt_content
    end
  end

  before do
    @view = BasicView.new
  end

  describe 'attributes' do
    it 'has a tag buffer' do
      @view.buffer.should == []
      @tag = Garterbelt::ContentTag.new(:view => @view, :type => :hr)
      @view.buffer << @tag
      @view.buffer.should == [@tag]
    end
    
    describe 'output' do
      it 'has an output' do
        @view.output.should == ""
      end
    
      it 'its output is that of the _curator if the _curator is not self' do
        BasicView.new(:_curator => @view).output.should === @view.output
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
    
    describe '_level' do
      it 'is 0 by default' do
        @view._level.should == 0
      end
      
      it 'can be set via initialization' do
        BasicView.new(:_level => 42)._level.should == 42
      end
    end
    
    it 'can be initailzed with a block' do
      view = BasicView.new do
        Garterbelt::Tag.new(:type => :p, :content => 'Initalization block content', :view => view)
      end
      view.block.is_a?(Proc).should be_true
    end
    
    it 'saves the initialization options' do
      view = BasicView.new(:foo => 'foo', :bar => 'bar')
      view.initialization_options.should == {:foo => 'foo', :bar => 'bar'}
    end
    
    it 'render_style defaults to :pretty' do
      view = BasicView.new
      view.render_style.should == :pretty
    end 
    
    describe 'setting the _curator: view responsible for displaying the rendered content' do
      before do
        @view._level = 42
        @view.output = "foo"
        @view.buffer = ["bar"]
        @view.escape = false
        @view.render_style = :text
        @child = BasicView.new(:_curator => @view)
      end
      
      it 'is self by default' do
        @view._curator.should == @view
      end
      
      it 'can be set' do
        @view._curator = BasicView.new
        @view._curator.should_not == @view
      end
      
      it 'can be intialized in' do
        BasicView.new(:_curator => @view)._curator.should == @view
      end
      
      describe 'resets other attributes' do
        it 'sets the output to the _curator\'s' do
          @child.output.should === @view.output
        end
        
        it 'sets the _level to the _curator\'s' do
          @child._level.should == @view._level
          @child._level.should == 42
        end
        
        it 'sets the buffer to the _curator\'s' do
          @child.buffer.should === @view.buffer
        end
        
        it 'sets the escape to the _curator\'s' do
          @child.escape.should == @view.escape
        end
        
        it 'sets the render_style to the _curator\'s' do
          @child.render_style.should == @view.render_style
        end
      end
    end
    
  end
end


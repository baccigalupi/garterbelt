require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::ContentTag do
  ContentTag = MarkupLounge::ContentTag unless defined?(ContentTag)
  
  before do
    @view = MockView.new
    @output = @view.output
    @params = {:type => :p, :attributes => {:class => 'classy'}, :view => @view}
    @tag = ContentTag.new(@params)
  end
  
  describe "basics" do
    it 'takes a content option' do
      ContentTag.new(@params.merge(:content => 'My great content')).content.should == "My great content"
    end
    
    it 'takes a block as content' do
      ContentTag.new(@params) do
        @output << "This is block content"
      end.content.class.should == Proc
    end
    
    it 'will override option content in favor of block content' do
      ContentTag.new(@params.merge(:content => 'not the block')) do
        @output << "This is block content"
      end.content.class.should == Proc
    end
    
    it 'inherits a really large max_pool_size' do
      ContentTag._pool.max_size.should == 10000
    end
  end
  
  describe 'chaining' do
    describe 'id' do
      it 'takes a block and sets it to content' do
        @tag.id(:foo) do
          @output << "This is block content"
        end
        @tag.content.class.should == Proc
      end
      
      it 'returns self' do
        @tag.id(:foo).should === @tag
      end
    end
    
    describe 'c' do
      it 'takes a block and sets it to content' do
        @tag.c(:foo) do
          @output << "This is block content"
        end
        @tag.content.class.should == Proc
      end
      
      it 'returns self' do
        @tag.c(:foo).should === @tag
      end
    end
  end
  
  describe 'rendering' do
    describe 'tags' do
      before do
        @tag.content = 'My string content'
        @tag.render
      end
      
      it 'indents the beginning tag correctly' do
        @output.should match /^    <p/
      end
      
      it 'renders the beginning tag correctly' do
        @output.should include "<p class='classy'>"
      end
      
      it 'indents the ending tag correctly' do
        @output.should match /^    <\/p/
      end
      
      it 'renders the ending tag correctly' do
        @output.should include "</p>"
      end
    end
    
    describe 'content' do
      describe 'none' do
        it 'works' do
          @tag.content.should be_nil
          @tag.render
          @output.should match "    <p class='classy'>\n    </p>"
        end
      end
      
      describe 'string' do
        before do
          @tag.content = "My string content"
          @tag.render
        end
        
        it 'is output' do
          @output.should include "My string content"
        end
        
        it 'is properly indented' do
          @output.should match /^      My/
        end
      end
      
      describe 'block' do
        describe 'writing directly to output' do
          before do
            @tag.id(:foo) do
              @output << "Going directly to the source"
            end
            @tag.render
          end
          
          it 'adds the content' do
            @output.should include "Going directly to the source"
          end
          
          it 'does not indent' do
            @output.should match /^Going/
          end
          
          it 'should put the content between the tags' do
            @output.should match /<p.*\nGoing directly to the source\n\W*<\/p/
          end
        end
        
        describe 'adding to the tag buffer' do
          before do
            @b = MarkupLounge::ClosedTag.new(:view => @view, :type => :hr, :attributes => {:class => :linear})
            @tag.id(:foo) do
              @view.buffer << @b
            end
          end
          
          it 'should add the tag to the buffer' do
            @tag.render
            @view.buffer.should include @b
          end
          
          it 'calls render buffer on the view' do
            @view.should_receive(:render_buffer)
            @tag.render
          end
        end
      end
    end
  end
end
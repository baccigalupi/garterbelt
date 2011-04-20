require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::ContentTag do
  ContentTag = Garterbelt::ContentTag unless defined?(ContentTag)
  
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
        @output.should include "<p class=\"classy\">"
      end
      
      it 'indents the ending tag correctly' do
        @output.should match /^    <\/p/
      end
      
      it 'renders the ending tag correctly' do
        @output.should include "</p>"
      end
    end
    
    describe 'styles' do
      before do
        @tag.content = "My string content"
        @view.render_style = :pretty
        @view.output = ''
      end
      
      describe ':minified' do
        before do
          @view.render_style = :minified
          @min = @tag.render
        end
        
        it 'does not end in a line break' do
          @min.should_not match  /\n$/
        end
        
        it 'does not have any indentation' do
          @min.should_not match /^\s{4}</
        end
      end
      
      describe ':text' do
        before do
          @view.render_style = :text
        end
        
        it 'has no tags' do
          @tag.render.should_not match /<[^>]>*/
        end
        
        [:p, :ul, :ol, :li].each do |type|
          it ":#{type} includes a line break" do
            @tag.type = type
            @tag.render.should match /\n/
          end
        end
        
        it 'has no line breaks othewise' do
          @tag.type = :div
          @tag.render.should_not match /\n/
        end
      end
    
      describe ':compact' do
        describe 'with block content' do
          it 'is just like pretty' do
            @tag.content = lambda { 'foo' }
            @tag.style = :pretty
            pretty = @tag.render
            @tag.style = :compact
            @tag.render.should == pretty
          end
        end
        
        describe 'with string content' do
          before do
            @tag.content = "stringy"
            @tag.style = :compact
            @compact = @tag.render
          end
          
          it 'head tag does not end in a break' do
            @compact.should match /<p[^>]*>/
            @compact.should_not match /<p[^>]*>\n/
          end
          
          it 'tail tag does not have any indentation' do
            @compact.should_not match />\s{1,50}<\/p>/
          end
        end
      end
    
      describe 'on initialization' do
        it 'uses the value passed in over the view render style' do
          @view.render_style = :pretty
          tag = ContentTag.new(@params.merge(:render_style => :minified, :content => 'my great content'))
          tag.style.should == :minified
        end
      end
    end
    
    describe 'content' do
      describe 'none' do
        it 'works' do
          @tag.content.should be_nil
          @tag.render
          @output.should match "    <p class=\"classy\">\n    </p>"
        end
      end
      
      describe 'string' do
        before do
          @tag.content = "My string content"
        end
        
        it 'makes a Text object' do
          Garterbelt::Text.should_receive(:new).and_return('text')
          @tag.render
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
            @output.should match /<p.*\nGoing.*<\/p/
          end
        end
        
        describe 'adding to the tag buffer' do
          before do
            @b = Garterbelt::ClosedTag.new(:view => @view, :type => :hr, :attributes => {:class => :linear})
            @tag.id(:foo) do
              @view._buffer << @b
            end
          end
          
          it 'should add the tag to the buffer' do
            @tag.render
            @view._buffer.should include @b
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
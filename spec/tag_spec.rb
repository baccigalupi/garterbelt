require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MarkupLounge::Tag do
  Tag = MarkupLounge::Tag unless defined?(Tag)
  
  class MockView
    attr_accessor :level, :output
    
    def initialize(l)
      self.output = ""
      self.level = l
    end
  end
  
  before do
    @view = MockView.new(2)
    @output = @view.output
    @params = {:type => :p, :attributes => {:class => 'classy'}, :view => @view}
    @tag = Tag.new(@params)
  end
  
  describe "initialize" do
    it 'takes a content option' do
      Tag.new(@params.merge(:content => 'My great content')).content.should == "My great content"
    end
    
    it 'takes a block as content' do
      Tag.new(@params) do
        @output << "This is block content"
      end.content.class.should == Proc
    end
    
    it 'will override option content in favor of block content' do
      Tag.new(@params.merge(:content => 'not the block')) do
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
        
        describe 'one tag layer deep' do
          before do
            @tag.id(:foo) do
              Tag.new(:type => :b, :content => 'Boldly going where everyone has gone before.', :view => @view).render
              Tag.new(:type => :a, :content => 'Link me', :view => @view, :attributes => {:href => '/go/foo/yourself'}).render
            end
            
            @tag.render
          end
          
          it 'adds the content' do
            @output.should include Tag.new(:type => :b, :content => 'Boldly going where everyone has gone before.', :view => @view).render
          end
          
          it 'adds the content in the correct order' do
            @output.should match /<p[^<]*<b/
          end
          
          it 'properly indents the content' do
            @output.should match /^        Boldly/
          end
          
          it 'works with multiple tags on the same level' do
            @output.should include "Link me"
            @output.should match /^        Link me/
          end
        end
        
        describe 'two layer tag nesting' do
          before do
            Tag.new(:type => :form, :view => @view, :attributes => {:action => '/foo/bar', :method => :post}) do
              Tag.new(:type => :fieldset, :view => @view) do
                MarkupLounge::ClosedTag.new(:type => :input, :view => @view, :attributes => {:name => 'my_great_input', :value => 'change me'}).render
              end.render
            end.render
          end
          
          it 'includes the second layer content' do
            @output.should match /<input[^>]*>/
          end
          
          it 'puts the second layer after the first' do
            @output.should match /<fieldset[^>]*>[^<]*<input[^>]*>[^<]*<\/fieldset>/
          end
          
          it 'is properly indented' do
            @output.should match /^        <input/        
          end
        end
      end
    end
  end
end
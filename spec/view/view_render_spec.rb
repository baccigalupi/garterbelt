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
    it 'has an output' do
      @view.output.should == ""
    end
    
    it 'has a tag buffer' do
      @view.buffer.should == []
      @tag = MarkupLounge::ContentTag.new(:view => @view, :type => :hr)
      @view.buffer << @tag
      @view.buffer.should == [@tag]
    end
  
    it 'has escape set to true by default' do
      @view.escape.should == true
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
    
    describe "render_buffer" do
      before do
        @hr = MarkupLounge::ContentTag.new(:view => @view, :type => :hr)
        @input = MarkupLounge::ContentTag.new(:view => @view, :type => :input)
        @img = MarkupLounge::ContentTag.new(:view => @view, :type => :img)
      end
      
      it 'will clear the buffer' do
        @view.buffer = [:foo]
        @view.render_buffer
        @view.buffer.should == []
      end
      
      it 'will call render on each tag in the buffer' do
        @view.buffer << @hr << @input << @img
        @hr.should_receive(:render)
        @input.should_receive(:render)
        @img.should_receive(:render)
        
        @view.render_buffer
      end
      
      it 'should recycle the tags' do
        @view.buffer << @hr << @input << @img
        @hr.stub(:render)
        @input.stub(:render)
        @img.stub(:render)
        
        @hr.should_receive(:recycle)
        @input.should_receive(:recycle)
        @img.should_receive(:recycle)
        
        @view.render_buffer
      end
      
      it 'will add non renderable items to the output as strings' do
        @view.buffer << "foo " << :bar
        @view.render_buffer
        @view.output.should include 'foo bar'
      end
    end
  
    describe 'tag nesting' do
      it 'should render correctly at one layer deep' do
        @view.buffer << MarkupLounge::ClosedTag.new(:type => :hr, :view => @view)
        @view.render.should == "<hr>\n"
      end
      
      describe 'second level' do
        before do
          @view.buffer << MarkupLounge::ContentTag.new(:type => :p, :view => @view) do
            @view.buffer << MarkupLounge::ClosedTag.new(:type => :hr, :view => @view)
          end
          @view.render
        end
        
        it 'should leave an empty buffer' do
          @view.buffer.should be_empty
        end
        
        it 'should include the content' do
          @view.output.should include "<hr>"
        end
        
        it 'should puts the nested tag inside the parent tag' do
          @view.output.should match /<p>\W*<hr>\W*<\/p>/
        end
      end
      
      describe 'multi level' do
        before do
          @view.buffer << MarkupLounge::ContentTag.new(:type => :form, :view => @view) do
            @view.buffer << MarkupLounge::ContentTag.new(:type => :fieldset, :view => @view) do
              @view.buffer << MarkupLounge::ContentTag.new(:type => :label, :view => @view, :attributes => {:for => 'email'}) do
                @view.buffer << MarkupLounge::ClosedTag.new(:type => :input, :view => @view, :attributes => {:name => 'email', :type => 'text'})
              end
              @view.buffer << MarkupLounge::ContentTag.new(:type => :input, :view => @view, :attributes => {:type => 'submit', :value => 'Login or whatever'})
            end
          end
          @view.render
        end
        
        it 'should include the deepest level content' do
          @view.output.should include "<input type='text' name='email'>"
        end
        
        it 'should nest properly' do
          @view.output.should match /<form>\W*<fieldset>\W*<label[^>]*>\W*<input/
        end
        
        it 'should indent properly' do
          @view.output.should match /^<form>/
          @view.output.should match /^  <fieldset>/
          @view.output.should match /^    <label/
          @view.output.should match /^      <input type='text'/
        end
        
        it 'should include content after the nesting' do
          @view.output.should include "<input type='submit' value='Login or whatever'"
          @view.output.should match /^    <input type='submit'/
        end
      end
    end
  
    describe 'class method' do
      before do
        @rendered = @view.render
        @view.stub(:recycle)
      end
      
      it 'makes a new view' do
        BasicView.should_receive(:new).and_return(@view)
        BasicView.render
      end
      
      it 'renders it' do
        BasicView.stub(:new).and_return(@view)
        @view.should_receive(:render)
        BasicView.render
      end
      
      it 'passes the :method option to render' do
        BasicView.stub(:new).and_return(@view)
        @view.should_receive(:render).with(:alt_content)
        BasicView.render :method => :alt_content
      end
      
      it 'recycles the view' do
        BasicView.stub(:new).and_return(@view)
        @view.should_receive(:recycle)
        BasicView.render
      end
      
      it 'returns the output' do
        BasicView.stub(:new).and_return(@view)
        BasicView.render.should == @rendered
      end
    end
  end

  describe 'tag helpers' do
    describe '#tag' do
      it 'makes a new tag' do
        MarkupLounge::ContentTag.should_receive(:new).with(
          :type => :p, :view => @view, :content => 'content', :attributes => {:class => 'classy'}
        ).and_return('content')
        @view.tag(:p, "content", {:class => 'classy'})
      end
      
      it 'returns the tag' do
        @view.tag(:p, "content", {:class => 'classy'}).is_a?(MarkupLounge::ContentTag).should be_true
      end
      
      it 'adds it to the buffer' do
        tag = @view.tag(:p, "content", {:class => 'classy'})
         @view.buffer.should include tag
      end
      
      it 'works with block content' do
        tag = @view.tag(:p, "content", {:class => 'classy'}) do
          @view.buffer << "foo"
        end
        tag.content.is_a?(Proc).should be_true
      end
    end
    
    describe '#closed_tag' do
      it 'makes a new closed tag' do
        MarkupLounge::ClosedTag.should_receive(:new).with(
          :type => :hr, :view => @view, :attributes => {:class => 'linear'}
        ).and_return('content')
        @view.closed_tag(:hr, :class => 'linear')
      end
      
      it 'returns the tag' do
        @view.closed_tag(:hr, :class => 'linear').is_a?(MarkupLounge::ClosedTag).should be_true
      end
      
      it 'adds it to the buffer' do
        tag = @view.closed_tag(:hr, :class => 'linear')
        @view.buffer.should include tag
      end
    end
  
    describe '#non_escape_tag' do
      it 'calls #tag' do
        @view.should_receive(:tag)
        @view.non_escape_tag(:pre, "<div>content</div>", {:class => 'classy'})
      end
      
      it 'sets and resets the escape when escape is originally set to true' do
        @view.should_receive(:escape=).with(false).ordered
        @view.should_receive(:tag).ordered
        @view.should_receive(:escape=).with(true).ordered
        @view.non_escape_tag(:pre, "<div>content</div>", {:class => 'classy'})
      end
      
      it 'does not set the escape when set to false' do
        @view.escape = false
        @view.should_not_receive(:escape=)
        @view.non_escape_tag(:pre, "<div>content</div>", {:class => 'classy'})
      end
    end
    
    describe '#text' do
      it 'makes a new Text' do
        MarkupLounge::Text.should_receive(:new).and_return('some content')
        @view.text("content")
      end
      
      it 'passes the right options to Text' do
        MarkupLounge::Text.should_receive(:new).with({
          :view => @view, :content => 'content'
        }).and_return('text renderer')
        @view.text("content")
      end
      
      it 'adds the Text object to the buffer' do
        @view.text("content")
        text = @view.buffer.last
        text.is_a?(MarkupLounge::Text).should be_true
        text.content.should == 'content'
      end
    end
    
    describe '#raw_text' do
      it 'calls #text' do
        @view.should_receive(:text).and_return('text')
        @view.raw_text("<div>foo</div>")
      end
      
      it 'sets escape before and after for a view that is set to escape' do
        @view.should_receive(:escape=).with(false).ordered
        @view.should_receive(:text).and_return('text')
        @view.should_receive(:escape=).with(true).ordered
        @view.raw_text("<div>foo</div>")
      end
      
      it 'does not set escape if the view is not escaping' do
        @view.escape = false
        @view.should_not_receive(:escape=)
        @view.raw_text("<div>foo</div>")
      end
    end
    
    describe 'html tag helpers' do
      describe 'content tags' do
        MarkupLounge::View::CONTENT_TAGS.each do |type|
          it "should have a method ##{type}" do
            @view.should respond_to(type)
          end
        
          it "##{type} should call #tag with argument content" do
            @view.should_receive(:tag).with(type.to_sym, "my great content", {:class => 'classy'})
            @view.send(type, "my great content", {:class => 'classy'})
          end
        
          it "##{type} should send along block content" do
            tag = @view.send(type, {:class => 'classy'}) do
              'foo'
            end
            tag.content.is_a?(Proc).should be_true
          end
        end
      end
      
      describe 'closed tags' do
        MarkupLounge::View::CLOSED_TAGS.each do |type|
          it "should have a method ##{type}" do
            @view.should respond_to(type)
          end
        
          it "##{type} should call #closed_tag with argument" do
            @view.should_receive(:closed_tag).with(type.to_sym, {:class => 'classy'})
            @view.send(type, {:class => 'classy'})
          end
        end
      end
      
      describe 'non-escaping tags' do
        MarkupLounge::View::NON_ESCAPE_TAGS.each do |tag|
          it "responds to :#{tag}" do
            @view.should respond_to(tag)
          end 

          it 'calls non_escape_tag' do
            @view.should_receive :non_escape_tag
            @view.send(tag)
          end
        end
      end
    
      describe 'comment' do
        it 'makes a comment object' do
          @view.comment('This is a comment.').is_a?(MarkupLounge::Comment).should be_true
        end
        
        it 'puts it on the buffer' do
          comment = @view.comment("new comment now")
          @view.buffer.last.should == comment
        end
      end
    end
    
  end
end
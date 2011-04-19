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
  
  describe 'rendering' do
    it 'clears the output on start' do
      @view.output = 'Foo the magic output!'
      @view.render
      @view.output.should_not include 'Foo the magic output!'
    end
    
    describe 'argument parsing' do
      describe 'render method' do
        it 'finds in as the first argument' do
          @view.should_receive(:bar)
          @view.render(:bar)
        end
        
        it 'finds it in the options' do
          @view.should_receive(:baz)
          @view.render :method => :baz
        end
      end
      
      describe ':style option' do
        it 'is found in options as the second argument' do
          @view.stub(:foo)
          @view.render(:foo, {:style => :minified})
          @view.render_style.should == :minified
        end
      
        it 'is found when options are the first argument' do
          @view.stub(:content)
          @view.render(:style => :text)
          @view.render_style.should == :text
        end
      end
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
        @hr = Garterbelt::ContentTag.new(:view => @view, :type => :hr)
        @input = Garterbelt::ContentTag.new(:view => @view, :type => :input)
        @img = Garterbelt::ContentTag.new(:view => @view, :type => :img)
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
      
      it 'will add non renderable items to the output as strings' do
        @view.buffer << "foo " << :bar
        @view.render_buffer
        @view.output.should include 'foo bar'
      end
    end
  
    describe 'tag nesting' do
      it 'should render correctly at one layer deep' do
        @view.buffer << Garterbelt::ClosedTag.new(:type => :hr, :view => @view)
        @view.render.should == "<hr>\n"
      end
      
      describe 'second level' do
        before do
          @view.buffer << Garterbelt::ContentTag.new(:type => :p, :view => @view) do
            @view.buffer << Garterbelt::ClosedTag.new(:type => :hr, :view => @view)
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
          @view.buffer << Garterbelt::ContentTag.new(:type => :form, :view => @view) do
            @view.buffer << Garterbelt::ContentTag.new(:type => :fieldset, :view => @view) do
              @view.buffer << Garterbelt::ContentTag.new(:type => :label, :view => @view, :attributes => {:for => 'email'}) do
                @view.buffer << Garterbelt::ClosedTag.new(:type => :input, :view => @view, :attributes => {:name => 'email', :type => 'text'})
              end
              @view.buffer << Garterbelt::ContentTag.new(:type => :input, :view => @view, :attributes => {:type => 'submit', :value => 'Login or whatever'})
            end
          end
          @view.render
        end
        
        it 'should include the deepest level content' do
          @view.output.should include "<input name=\"email\" type=\"text\">"
        end
        
        it 'should nest properly' do
          @view.output.should match /<form>\W*<fieldset>\W*<label[^>]*>\W*<input/
        end
        
        it 'should indent properly' do
          @view.output.should match /^<form>/
          @view.output.should match /^  <fieldset>/
          @view.output.should match /^    <label/
          @view.output.should match /^      <input name="email"/
        end
        
        it 'should include content after the nesting' do
          @view.output.should include "<input type=\"submit\" value=\"Login or whatever\""
          @view.output.should match /^    <input type="submit"/
        end
      end
    end
  
    describe 'class method' do
      before do
        @rendered = @view.render
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
      
      it 'returns the output' do
        BasicView.stub(:new).and_return(@view)
        BasicView.render.should == @rendered
      end
    end

    describe 'block initalized content' do
      it 'has a #render_block method that renders that content' do
        @view = BasicView.new do
          @view.buffer << Garterbelt::ContentTag.new(:type => :p, :view => @view, :content => 'Block level p tag')
        end
        @view.render_block.should include "Block level p tag"
      end
      
      it 'passes the block to the content method' do
        class PassItOn < Garterbelt::View
          def content
            p do
              yield
            end
          end
        end
        
        @view = PassItOn.new do
          @view.buffer << Garterbelt::ContentTag.new(:type => :span, :view => @view, :content => 'spanning it up!')
        end
        
        @view.render.should include "spanning it up!"
      end
    end
  end

  describe 'renderers' do
    describe '#tag' do
      it 'makes a new tag' do
        Garterbelt::ContentTag.should_receive(:new).with(
          :type => :p, :view => @view, :content => 'content', :attributes => {:class => 'classy'}
        ).and_return('content')
        @view.tag(:p, "content", {:class => 'classy'})
      end
      
      it 'returns the tag' do
        @view.tag(:p, "content", {:class => 'classy'}).is_a?(Garterbelt::ContentTag).should be_true
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
        Garterbelt::ClosedTag.should_receive(:new).with(
          :type => :hr, :view => @view, :attributes => {:class => 'linear'}
        ).and_return('content')
        @view.closed_tag(:hr, :class => 'linear')
      end
      
      it 'returns the tag' do
        @view.closed_tag(:hr, :class => 'linear').is_a?(Garterbelt::ClosedTag).should be_true
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
        @view.should_receive(:_escape=).with(false).ordered
        @view.should_receive(:tag).ordered
        @view.should_receive(:_escape=).with(true).ordered
        @view.non_escape_tag(:pre, "<div>content</div>", {:class => 'classy'})
      end
      
      it 'does not set the escape when set to false' do
        @view._escape = false
        @view.should_not_receive(:_escape=)
        @view.non_escape_tag(:pre, "<div>content</div>", {:class => 'classy'})
      end
    end
    
    describe '#text' do
      it 'makes a new Text' do
        Garterbelt::Text.should_receive(:new).and_return('some content')
        @view.text("content")
      end
      
      it 'passes the right options to Text' do
        Garterbelt::Text.should_receive(:new).with({
          :view => @view, :content => 'content'
        }).and_return('text renderer')
        @view.text("content")
      end
      
      it 'adds the Text object to the buffer' do
        @view.text("content")
        text = @view.buffer.last
        text.is_a?(Garterbelt::Text).should be_true
        text.content.should == 'content'
      end
    end
    
    describe '#raw_text' do
      it 'calls #text' do
        @view.should_receive(:text).and_return('text')
        @view.raw_text("<div>foo</div>")
      end
      
      it 'sets escape before and after for a view that is set to escape' do
        @view.should_receive(:_escape=).with(false).ordered
        @view.should_receive(:text).and_return('text')
        @view.should_receive(:_escape=).with(true).ordered
        @view.raw_text("<div>foo</div>")
      end
      
      it 'does not set escape if the view is not escaping' do
        @view._escape = false
        @view.should_not_receive(:_escape=)
        @view.raw_text("<div>foo</div>")
      end
    end
    
    describe 'html tag helpers' do
      describe 'content tags' do
        Garterbelt::View::CONTENT_TAGS.each do |type|
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
        Garterbelt::View::CLOSED_TAGS.each do |type|
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
        Garterbelt::View::NON_ESCAPE_TAGS.each do |tag|
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
          @view.comment_tag('This is a comment.').is_a?(Garterbelt::Comment).should be_true
        end
        
        it 'puts it on the buffer' do
          comment = @view.comment_tag("new comment now")
          @view.buffer.last.should == comment
        end
      end
    
      describe 'doctype' do
        it 'makes a Doctype object' do
          @view.doctype(:html5).is_a?(Garterbelt::Doctype).should be_true
        end
        
        it 'puts it on the buffer' do
          doctype = @view.doctype
          @view.buffer.last.should == doctype
        end
      end
    
      describe 'xml' do
        it 'adds an xml to the buffer' do
          xml = @view.xml
          xml.is_a?(Garterbelt::Xml).should be_true
          @view.buffer.last.should == xml
        end
        
        it 'makes a closed tag with default options' do
          xml = @view.xml
          xml.attributes[:version].should == 1.0
          xml.attributes[:encoding].should == 'utf-8'
        end
        
        it 'uses custom attributes when desired' do
          xml = @view.xml(:version => 0)
          xml.attributes[:version].should == 0
          xml.attributes[:encoding].should == 'utf-8'
        end
      end
    
      describe 'head tags' do
        Garterbelt::View::HEAD_TAGS.each do |type|
          describe "_#{type}" do
            it "it is a method" do
              @view.should respond_to("_#{type}")
            end
          
            it "makes a closed tag" do
              @view.should_receive(:closed_tag).with(type.to_sym)
              @view.send("_#{type}")
            end
          end
        end
        
        describe 'page_title' do
          it 'makes a content tag of type :title' do
            @view.should_receive(:tag).with(:title, "My Great Page Title!")
            @view.page_title "My Great Page Title!"
          end
        end
        
        describe 'helpers' do
          it 'stylesheet_link makes a link closed tag with the right options' do
            @view.should_receive(:_link).with(:rel => "stylesheet", 'type' => "text/css", :href => "/foo/theme.css")
            @view.stylesheet_link('/foo/theme')
          end
          
          it 'javascript_link makes a script tag with the right options' do
            @view.should_receive(:script).with( :src => "/foo/script.js", 'type' => "text/javascript")
            @view.javascript_link('/foo/script')
          end
        end
      end
    end
  end
end
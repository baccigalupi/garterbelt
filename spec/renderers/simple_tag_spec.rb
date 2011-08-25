require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::SimpleTag do
  SimpleTag = Garterbelt::SimpleTag unless defined?(SimpleTag)
  
  before do
    @view = MockView.new
  end
  
  describe 'initialize' do
    it 'requires a type' do
      lambda{ SimpleTag.new({:view => @view}) }.should raise_error(ArgumentError, ":type required in initialization options")
    end
    
    it 'requires a view' do
      lambda{ SimpleTag.new({:type => :input}) }.should raise_error(ArgumentError, ":view required in initialization options")
    end
    
    it 'store the type as an attribute' do
      SimpleTag.new({:type => :input, :view => @view}).type.should == :input
    end
    
    it 'attributes should be empty by default' do
      SimpleTag.new(:type => :input, :view => @view).attributes.should == {}
    end
    
    it 'sets the attributes' do
      SimpleTag.new(:type => :input, :attributes => {:foo => :bar}, :view => @view).attributes.should == {:foo => :bar}
    end
    
    it 'extracts css_class into its own variable' do
      SimpleTag.new(:type => :input, :attributes => {:class => :foo}, :view => @view).css_class.should == [:foo]
    end
  end
  
  describe 'method chaining' do
    before do
      @tag = SimpleTag.new(:type => :input, :view => @view)
    end
    
    describe '#id' do
      it 'adds an id attribute' do
        @tag.id(:foo).attributes[:id].should == :foo
      end
      
      it 'raises an argument error if passed an array or something non-stringy' do
        lambda{ @tag.id([:foo, :bar]) }.should raise_error(ArgumentError, "Id must be a String or Symbol")
      end
      
      it 'returns self' do
        @tag.id(:foo).should === @tag
      end
    end
    
    describe '#c' do
      it 'adds the value to the css_class' do
        @tag.c(:foo).css_class.should == [:foo]
      end
      
      it 'will not overwrite existing css classes' do
        @tag.c(:foo).css_class.should == [:foo]
        @tag.c(:bar).css_class.should == [:foo, :bar]
      end
      
      it 'takes any number of arguments' do
        @tag.c(:foo, :bar).css_class.should == [:foo, :bar]
      end
      
      it 'returns self' do
        @tag.c(:foo, :bar).should === @tag
      end
    end
    
    describe 'method_missing' do
      it 'should convert ! methods to id attributes' do
        @tag.foo!
        @tag.attributes[:id].to_s.should == 'foo'
      end
      
      it 'should convert other methods to classes' do
        @tag.bar
        @tag.css_class.should == [:bar]
      end
      
      it 'continues to chain' do
        @tag.foo!.bar
        @tag.attributes[:id].to_s.should == 'foo'
        @tag.css_class.should == [:bar]
      end
      
      it 'passes to super when arguments are given' do
        expect{ @tag.foo!(:bar) }.should raise_error
      end
      
      it 'passes to super when a block is given' do
        expect do 
          @tag.foo { 'do something here' }
        end.should raise_error
      end
    end
  end
  
  describe 'view usage' do
    before do
      @tag = SimpleTag.new(:type => :input, :view => @view)
    end
    
    it 'uses its output' do
      @tag.output.should == @view.output
    end
    
    it 'uses its level' do
      @tag.level.should == 2
    end
  end
  
  
  describe 'rendering' do
    before do
      @tag = SimpleTag.new(
        :type => :input, 
        :attributes => {:class => :foo_bar, :thing => :thong},
        :view => @view
      )
    end
    
    it 'indent corresponding to the view _level' do
      @tag.indent.should == "    "
      @tag.stub(:level).and_return(1)
      @tag.indent.should == "  "
      @tag.stub(:level).and_return(0)
      @tag.indent.should == ""
    end
    
    describe '#rendered_attributes' do
      it 'includes the css_class' do
        @tag.rendered_attributes.should include "class=\"foo_bar\""
      end
      
      it 'multiple classes are separated by a space' do
        @tag.c(:more_classy)
        @tag.rendered_attributes.should include "class=\"foo_bar more_classy\""
      end
      
      it 'include other key/value pairs' do
        @tag.rendered_attributes.should include "thing=\"thong\""
      end
      
      it 'does not include attributes with nil or false values' do
        @tag.attributes[:checked] = false
        @tag.attributes[:nily] = nil
        rendered = @tag.rendered_attributes
        rendered.should_not include "checked=\"\""
        rendered.should_not include "nily=\"\""
      end
      
      it 'should subs out double quotes from attributes' do
        @tag.attributes[:foo_title] = 'I am not "sure" if this will work'
        @tag.rendered_attributes.should include "I am not 'sure' if this will work"
      end
    end
    
    describe 'integration (:pretty style)' do
      before do
        @str = @tag.render
      end
      
      it 'starts with the indent' do
        @str.should match /^\W{4}</
      end
      
      it 'includes the full tag' do
        @str.should match /<input[^>]*>/
      end
      
      it 'includes the attributes' do
        @str.should match /<input#{@tag.rendered_attributes}>/
      end
      
      it 'ends with the closing tag and a line break' do
        @str.should match /\n$/
      end
      
      it 'adds the string to the output' do
        @view.output.should include @str
      end
    end
    
    describe 'styles' do
      before do
        @tag = SimpleTag.new(:type => :input, :view => @view)
        @view.render_style = :pretty
        @pretty = @tag.render
      end
      
      describe ':minified' do
        before do
          @tag.style = :minified
          @min = @tag.render
        end
        
        it 'does not end in a line break' do
          @min.should_not match  /\n$/
        end
        
        it 'does not have any indentation' do
          @pretty.should match /^\s{4}</
          @min.should_not match /^\s{4}</
        end
      end
      
      describe ':text' do
        it 'is an empty string' do
          @tag.style = :text
          @tag.render.should == ''
        end
      end
    end
  end
end

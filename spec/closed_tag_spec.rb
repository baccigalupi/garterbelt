require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MarkupLounge::ClosedTag do
  ClosedTag = MarkupLounge::ClosedTag unless defined?(ClosedTag)
  
  before do
    @output = ''
    @view = mock(:output => @output, :level => 2)
  end
  
  describe 'initialize' do
    it 'requires a type' do
      lambda{ ClosedTag.new({:view => @view}) }.should raise_error(ArgumentError, ":type required in initialization options")
    end
    
    it 'requires a view' do
      lambda{ ClosedTag.new({:type => :input}) }.should raise_error(ArgumentError, ":view required in initialization options")
    end
    
    it 'store the type as an attribute' do
      ClosedTag.new({:type => :input, :view => @view}).type.should == :input
    end
    
    it 'attributes should be empty by default' do
      ClosedTag.new(:type => :input, :view => @view).attributes.should == {}
    end
    
    it 'sets the attributes' do
      ClosedTag.new(:type => :input, :attributes => {:foo => :bar}, :view => @view).attributes.should == {:foo => :bar}
    end
    
    it 'extracts css_class into its own variable' do
      ClosedTag.new(:type => :input, :attributes => {:class => :foo}, :view => @view).css_class.should == [:foo]
    end
  end
  
  describe 'pooling' do
    it 'include RuPol::Swimsuit' do
      ClosedTag.ancestors.should include(RuPol::Swimsuit)
    end
    
    it 'has a really large max_pool_size' do
      ClosedTag._pool.max_size.should == 10000
    end
  end
  
  describe 'method chaining' do
    before do
      @tag = ClosedTag.new(:type => :input, :view => @view)
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
  end
  
  describe 'view usage' do
    before do
      @tag = ClosedTag.new(:type => :input, :view => @view)
    end
    
    it 'uses its output' do
      @tag.output.should == @output
    end
    
    it 'uses its level' do
      @tag.level.should == 2
    end
  end
  
  
  describe 'rendering' do
    before do
      @tag = ClosedTag.new(
        :type => :input, 
        :attributes => {:class => :foo_bar, :thing => :thong},
        :view => @view
      )
    end
    
    it 'indent corresponding to the view level' do
      @tag.indent.should == "    "
      @tag.stub(:level).and_return(1)
      @tag.indent.should == "  "
      @tag.stub(:level).and_return(0)
      @tag.indent.should == ""
    end
    
    describe '#rendered_attributes' do
      it 'includes the css_class' do
        @tag.rendered_attributes.should include "class='foo_bar'"
      end
      
      it 'multiple classes are separated by a space' do
        @tag.c(:more_classy)
        @tag.rendered_attributes.should include "class='foo_bar more_classy'"
      end
      
      it 'include other key/value pairs' do
        @tag.rendered_attributes.should include "thing='thong'"
      end
    end
    
    describe 'integration' do
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
        @output.should include @str
      end
    end
  end
end

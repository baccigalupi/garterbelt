require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MarkupLounge::Tag do
  Tag = MarkupLounge::Tag unless defined?(Tag)
  
  describe 'initialize' do
    it 'requires a type' do
      lambda{ Tag.new({}) }.should raise_error(ArgumentError, ":type required in initialization options")
    end
    
    it 'store the type as an attribute' do
      Tag.new({:type => :p}).type.should == :p
    end
    
    it 'has a default level of 0' do
      Tag.new({:type => :p}).level.should == 0
    end
    
    it 'level can be customized' do
      Tag.new(:type => :p, :level => 2).level.should == 2
    end
    
    it 'attributes should be empty by default' do
      Tag.new(:type => :p).attributes.should == {}
    end
    
    it 'sets the attributes' do
      Tag.new(:type => :p, :attributes => {:foo => :bar}).attributes.should == {:foo => :bar}
    end
    
    it 'extracts css_class into its own variable' do
      Tag.new(:type => :p, :attributes => {:class => :foo}).css_class.should == [:foo]
    end
    
    it 'sets the content when it receives it as an argument' do
      Tag.new(:type => :p, :content => 'foo').content.should == 'foo'
    end
    
    it 'sets the content to a block if it receives a block' do
      Tag.new(:type => :p) do
        puts 'foo'
      end.content.class.should == Proc
    end
    
    it 'will set content to the block rather than the argument if both are received' do
      Tag.new(:type => :p, :content => 'bar') do
        puts 'foo'
      end.content.class.should == Proc
    end
  end
  
  describe 'pooling' do
    it 'include RuPol::Swimsuit' do
      Tag.ancestors.should include(RuPol::Swimsuit)
    end
    
    it 'has a really large max_pool_size' do
      Tag._pool.max_size.should == 10000
    end
  end
  
  describe 'method chaining' do
    before do
      @tag = Tag.new(:type => :p)
    end
    
    describe '#id' do
      it 'adds an id attribute' do
        @tag.id(:foo).attributes[:id].should == :foo
      end
      
      it 'raises an argument error if passed an array or something non-stringy' do
        lambda{ @tag.id([:foo, :bar]) }.should raise_error(ArgumentError, "Id must be a String or Symbol")
      end
      
      it 'takes a block and sets it to the content' do
        @tag.content.should be_nil
        @tag.id(:bar) { 'foo' }
        @tag.content.class.should == Proc
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
      
      it 'takes a block and sets it to the content' do
        @tag.content.should be_nil
        @tag.c(:foo, :bar) { puts 'string' }
        @tag.content.class.should == Proc
      end
      
      it 'returns self' do
        @tag.c(:foo, :bar).should === @tag
      end
    end
  end
  
  describe 'rendering' do
    before do
      @tag = Tag.new(:type => :p, :content => 'foo', :level => 2, :attributes => {:class => :foo_bar, :thing => :thong})
    end
    
    it 'indent corresponding to the level' do
      @tag.indent.should == "    "
      @tag.level = 1
      @tag.indent.should == "  "
      @tag.level = 0
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
    
    describe '#rendered_content' do
      it 'includes the content if it is a stringish thing' do
        @tag.rendered_content.should == 'foo'
      end
      
      it 'renders the block otherwise'
    end
    
    describe 'integration' do
      it 'starts with the indent' do
        @tag.render.should match /^\W{4}</
      end
      
      it 'includes the opening tag' do
        @tag.render.should match /<p[^>]*>/
      end
      
      it 'include the content in the middle' do
        @tag.render.should match />foo</
      end
      
      it 'includes the attributes' do
        @tag.render.should match /<p#{@tag.rendered_attributes}>/
      end
      
      it 'ends with the closing tag and a line break' do
        @tag.render.should match /<\/p>\n/
      end
    end
  end
end

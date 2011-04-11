require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::Cache do
  before :all do
    @view = MockView.new
  end

  def build_cache
    MarkupLounge::Cache.new(:key => 'good_deal', :view => @view) do
      MarkupLounge::ContentTag.new(:type => :p, :view => @view)
    end
  end
  
  describe 'initialization' do
    it 'requires block content' do
      lambda{ MarkupLounge::Cache.new(:key => 'foo_key', :view => @view)}.should raise_error(ArgumentError, "Block content required")
      lambda{ MarkupLounge::Cache.new(:key => 'other_foo', :view => @view, :content => 'content')}.should raise_error( ArgumentError, "Block content required")
    end
    
    it 'requires a key' do
      lambda{ MarkupLounge::Cache.new(:view => @view) {puts 'foo'} }.should raise_error(ArgumentError, ":key option required")
    end
    
    it 'otherwise is successful' do
      lambda{ build_cache }.should_not raise_error
      build_cache.is_a?(MarkupLounge::Cache).should be_true
    end
    
    it 'stores the full key' do
      build_cache.key.should == 'good_deal'
    end
  end
  
  describe 'rendering' do
    describe 'cache calling' do
      it 'trys to get the content from the cache using the full key'
      it 'calls #render_content if cache misses'
      it 'puts the cache into the output when it hits'
    end
    
    describe '#render_content' do
      it 'diverts view output to a local string'
      it 'renders the block content'
      it 'return view output to original string'
    end
  end
end

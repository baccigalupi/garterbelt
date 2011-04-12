require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::Cache do
  before :all do
    @view = MockView.new
  end

  def build_cache
    Garterbelt::Cache.new(:key => 'good_deal', :view => @view) do
      Garterbelt::ContentTag.new(:type => :p, :view => @view)
    end
  end
  
  describe 'initialization' do
    it 'requires block content' do
      lambda{ Garterbelt::Cache.new(:key => 'foo_key', :view => @view)}.should raise_error(ArgumentError, "Block content required")
      lambda{ Garterbelt::Cache.new(:key => 'other_foo', :view => @view, :content => 'content')}.should raise_error( ArgumentError, "Block content required")
    end
    
    it 'requires a key' do
      lambda{ Garterbelt::Cache.new(:view => @view) {puts 'foo'} }.should raise_error(ArgumentError, ":key option required")
    end
    
    it 'otherwise is successful' do
      lambda{ build_cache }.should_not raise_error
      build_cache.is_a?(Garterbelt::Cache).should be_true
    end
    
    it 'stores the full key' do
      build_cache.key.should == 'good_deal'
    end
    
    it 'stores the expiration information' do
      cache = Garterbelt::Cache.new(:key => 'expiring_deal', :view => @view, :expires_in => 3600) do # one hour, in seconds
        Garterbelt::ContentTag.new(:type => :p, :view => @view)
      end
      cache.expires_in.should == 3600
    end
  end
  
  describe 'rendering' do
    before do
      @cache = build_cache
    end
    
    describe "diverting output" do
      before do
        @cache.cache_output = "cache output"
        @view.output = 'view output; '
      end
      
      it '#head changes the view output to a local output' do
        @cache.head
        @view.output.should == "cache output"
      end
      
      it '#foot resets the output to the original view output' do
        @cache.head
        @view.output.should_not include "view output; "
        @cache.foot
        @view.output.should include "view output; "
      end
      
      it '#render calls #head and #foot' do
        @cache.should_receive(:head).ordered
        @cache.should_receive(:foot).ordered
        @cache.render
      end
    end
    
    describe '#render_content' do
      it 'trys to get the content from the cache using the key' do
        @view.cache_store.should_receive(:[]).with('good_deal').and_return("foo")
        @cache.render
      end
    
      it 'puts the cache into the output when it hits' do
        @view.output = "view output; "
        @view.cache_store.stub(:[]).with('good_deal').and_return("foo")
        @cache.render
        @view.output.should include 'foo'
      end
    
      it 'renders the block when the cache misses' do
        @view.output = "view output; "
        @view.cache_store.should_receive(:[]).with('good_deal').and_return(nil)
        @view.should_receive(:render_buffer)
        @cache.render
      end
      
      it 'adds puts the render block into the cache' do
        @view.output = "view output; "
        @view.cache_store.should_receive(:[]).with('good_deal').and_return(nil)
        @view.stub(:render_buffer).and_return('buffer rendered')
        @view.cache_store.should_receive(:store).with('good_deal', @cache.cache_output, {})
        @cache.render
      end
      
      it 'uses the expiration when it has one' do
        cache = Garterbelt::Cache.new(:key => 'good_deal', :view => @view, :expires_in => 3600) do
          Garterbelt::ContentTag.new(:type => :p, :view => @view)
        end
        
        @view.output = "view output; "
        @view.cache_store.should_receive(:[]).with('good_deal').and_return(nil)
        @view.stub(:render_buffer).and_return('buffer rendered')
        
        @view.cache_store.should_receive(:store).with('good_deal', cache.cache_output, {:expires_in => 3600})
        cache.render
      end
    end
  end
end

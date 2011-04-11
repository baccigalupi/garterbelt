require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View, "Caching" do
  class Cached < MarkupLounge::View
  end
  
  class SpecialCached < MarkupLounge::View
    def self.cache_store_key
      :foo
    end
  end
  
  describe 'cache access' do
    describe 'class level #cache_store_key' do
      it 'defaults to :default' do
        MarkupLounge::View.cache_store_key.should == :default
        Cached.cache_store_key.should == :default
      end
      
      it 'can be customized' do
        SpecialCached.cache_store_key.should == :foo
      end
    end
    
    describe 'instance level #cache_store_key' do
      it 'defaults to the class' do
        Cached.new.cache_store_key.should == :default
        SpecialCached.new.cache_store_key.should == :foo
      end
      
      it 'can be set independently' do
        cached = Cached.new
        cached.cache_store_key = :boo
        cached.cache_store_key.should == :boo
      end
    end
    
    describe 'cache_store' do
      it 'returns a cache object' do
        Cached.new.cache_store.should == MarkupLounge.cache
      end
      
      it 'uses the instance level cache_store_key' do
        cached = Cached.new
        MarkupLounge.cache_hash[:foo] = 'foo'
        cached.cache_store_key = :foo
        cached.cache_store.should == 'foo'
      end
    end
    
    describe 'cache key base' do
      describe 'class level' do
        it 'is the underscored version of the class by default' do
          Cached.cache_key_base.should == 'cached'
          SpecialCached.cache_key_base.should == 'special_cached'
        end
        
        it 'can be customized' do
          Cached.cache_key_base = 'custom_cache_key_base'
          Cached.cache_key_base.should == 'custom_cache_key_base'
        end
      end
      
      describe 'instance level' do
        it 'defaults to the class' do
          Cached.cache_key_base = 'cached'
          Cached.new.cache_key_base.should == 'cached'
        end
        
        it 'can be customized, which is probably a bad idea, but maybe necessary in crappy code' do
          Cached.cache_key_base.should == 'cached'
          cached = Cached.new
          cached.cache_key_base = 'foo'
          cached.cache_key_base.should == 'foo'
        end
      end
    end
    
    describe '#cache_key' do
      it 'it contains the instance level base' do
        cache = Cached.new
        cache.cache_key.should include "cached"
        cache.cache_key_base = 'foo'
        cache.cache_key.should include 'foo'
      end
      
      it 'has a default _default argument that is concatenated' do
        cache = Cached.new
        cache.cache_key.should == 'cached_default'
      end
      
      it 'takes a custom key argument' do
        cache = Cached.new
        cache.cache_key(:foo).should == 'cached_foo'
      end
      
      it 'uses the default when passed nil' do
        cache = Cached.new
        cache.cache_key(nil).should == 'cached_default'
      end
    end
  end
  
  describe '#cache' do
    before do
      @view = Cached.new
    end
    
    it 'makes a Cache object' do
      MarkupLounge::Cache.should_receive(:new).and_return('foo')
      @view.cache("user_8") do
        puts "bar"
      end
    end
    
    it 'passes the correct key and the view' do
      MarkupLounge::Cache.should_receive(:new).with(:view => @view, :key => "cached_user_8").and_return('foo')
      @view.cache("user_8") do
        puts "bar"
      end
    end
    
    it 'adds the Cache object to the render buffer' do
      @view.cache("foo_you") do
        puts "bar"
      end
      cache = @view.buffer.last
      cache.is_a?(MarkupLounge::Cache).should be_true
      cache.key.should == 'cached_foo_you'
    end
  end
end
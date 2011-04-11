require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View, "Caching" do
  class Cached < MarkupLounge::View
  end
  
  class SpecialCached < MarkupLounge::View
    def self.cache_store
      :foo
    end
  end
  
  describe 'cache access' do
    describe 'class level #cache_store' do
      it 'defaults to :default' do
        MarkupLounge::View.cache_store.should == :default
        Cached.cache_store.should == :default
      end
      
      it 'can be customized' do
        SpecialCached.cache_store.should == :foo
      end
    end
    
    describe 'instance level #cache_store' do
      it 'defaults to the class' do
        Cached.new.cache_store.should == :default
        SpecialCached.new.cache_store.should == :foo
      end
      
      it 'can be set independently' do
        cached = Cached.new
        cached.cache_store = :boo
        cached.cache_store.should == :boo
      end
    end
    
    describe 'cache' do
      it 'returns a cache object' do
        Cached.new.cache.should == MarkupLounge.cache
      end
      
      it 'uses the instance level cache_store' do
        cached = Cached.new
        MarkupLounge.cache_hash[:foo] = 'foo'
        cached.cache_store = :foo
        cached.cache.should == 'foo'
      end
    end
  end
end
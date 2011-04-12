require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Garterbelt do
  describe 'cache module level methods' do
    describe '#cache_hash' do
      it 'creates a default hash when accessed the first time' do
        cache_hash = Garterbelt.cache_hash.dup
        cache_hash.class.should == Hash
        cache_hash[:default].is_a?(Moneta::Memory).should == true
        cache_hash.keys.size.should == 1
      end
      
      it 'gives direct access to the hash' do
        Garterbelt.cache_hash[:foo] = 'foo'
        Garterbelt.cache_hash[:foo].should == 'foo'
      end
    end
    
    describe '#cache=' do
      it 'creates a Moneta cache' do
        
      end
      
      describe 'options' do
        it 'creates a memory Moneta cache correctly'
        it 'creates a file system Moneta cache'
        it 'creates alternative types as requested'
      end
      it 'sets the default key when not provided a argument'
      it 'sets other keys when not '
    end
    
    describe '#cache' do
      it 'returns the :default if no arugment is received' do
        Garterbelt.cache.should == Garterbelt.cache_hash[:default]
      end
      
      it 'returns an alternative cache by key' do
        Garterbelt.cache_hash[:foo] = 'foo'
        Garterbelt.cache(:foo).should == 'foo'
      end
      
      it 'raises an error when accessing via a key that has no been configured' do
        Garterbelt.cache_hash[:bar].should be_nil
        lambda { Garterbelt.cache(:bar) }.should raise_error( "Cache :bar has not yet been configured" )
      end
    end
  end
end

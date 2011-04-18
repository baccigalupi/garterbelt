require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe String, 'extension' do
  describe '#wrap(limit, opts)' do
    describe 'limiting' do
      it 'does not require arguments' do
        lambda {''.wrap}.should_not raise_error
      end
    
      it 'doesn\'t break a string without spaces' do
        breakless = "123"*50
        breakless.wrap.should == breakless
      end
    
      it 'defaults to 50 characters if not given a limit' do
        space_at_five = '1234 '*70
        space_at_five.wrap.should match /^#{'1234 '*9}1234\n/
      end
    
      it 'takes an alternate limit' do
        space_at_five = '1234 '*70
        space_at_five.wrap(100).should match /^#{'1234 '*19}1234\n/
      end
    
      it 'does not break in the middle of a word' do
        '1234567 foo'.wrap(5).should == "1234567\nfoo"
      end
    
      it 'does nothing in a string that is shorter than the limit' do
        '12345'.wrap.should == '12345'
      end
    end
    
    describe 'indent option' do
      it 'appends it to the front of each line' do
        space_at_five = '1234 '*5
        space_at_five.wrap(10, :indent => ' '*5).split(' '*5).size.should == 6
      end
      
      it 'takes the indent into account when choosing a break point' do
        space_at_five = '1234 '*70
        str = "     1234 1234 1234 1234 1234 1234 1234 1234 1234"
        space_at_five.wrap(50, :indent => ' '*5).should match /^#{str}\n/
      end
      
      it 'adds the indent to returned strings even if not wrapping' do
        'string'.wrap(10, :indent => '   ').should == '   string'
      end
    end
  end
end
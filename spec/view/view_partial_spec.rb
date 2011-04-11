require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View, 'Partials' do
  describe '#partial' do
    before do
      @view = MarkupLounge::View.new
    end
    
    describe 'with an instance' do
      it 'sets the curator of the instance to the current view'
      it 'adds the instance to the buffer'
    end
    
    describe 'with a class and initialization options' do
      it 'constructs a new instance'
      it 'has the currator as the current view'
      it 'has the correct initalization options'
      it 'passes along the block'
      it 'adds the instance to the buffer'
    end
  end
end
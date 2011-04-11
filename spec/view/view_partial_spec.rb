require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View, 'Partials' do
  describe '#partial' do
    before do
      @view = MarkupLounge::View.new
      @view.output = "Foo You!\n"
      @view.level = 3
      @view.buffer = ['foo', 'bar']
    end
    
    describe 'with an instance' do
      before do
        @child_instance = MarkupLounge::View.new
      end
      
      it 'sets the curator of the instance to the current view' do
        @child_instance.should_receive(:curator=).with(@view)
        @view.partial(@child_instance)
      end
      
      it 'adds the instance to the curator view buffer' do
        @view.partial(@child_instance)
        @view.buffer.should include @child_instance
      end
    end
    
    describe 'with a class and initialization options' do
      class PartedOut < MarkupLounge::View
        needs :x => 'x'
        def content
          text "foo #{x}"
        end
      end
      
      it 'constructs a new instance' do
        @part = PartedOut.new
        PartedOut.should_receive(:new).and_return(@part)
        @view.partial(PartedOut, :x => '!= x')
      end
      
      it 'adds the instance to the buffer' do
        @view.partial(PartedOut, :x => '!= y?')
        partial = @view.buffer.last
        partial.is_a?(PartedOut).should be_true
      end
      
      
      it 'has the curator as the current view' do
        @view.partial(PartedOut, :x => 'what about z?')
        partial = @view.buffer.last
        partial.curator.should == @view
      end
      
      it 'has the correct initalization options' do
        @view.partial(PartedOut, :x => '= foo')
        partial = @view
      end
      
      it 'passes along the block, wait do views take blocks right now?'
    end
  end
end
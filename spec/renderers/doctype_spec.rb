require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::Doctype do
  before :all do
    @view = MockView.new
  end
  
  describe 'basics' do
    it 'is decends from SimpleTag' do
      Garterbelt::Doctype.ancestors.should include Garterbelt::SimpleTag
    end
  end
  
  describe 'render' do
    before do
      @view = MockView.new
      @doctype = Garterbelt::Doctype.new(:view => @view, :type => :transitional)
    end
    
    it 'builds the right tag for type = :transitional' do
      tag = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
      @doctype.render.should include tag
    end
    
    it 'builds the right tag for type = :strict' do
      tag = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
      @doctype.type = :strict
      @doctype.render.should include tag
    end
    
    it 'builds the right tag for type = :html5' do
      tag = '<!DOCTYPE html>'
      @doctype.type = :html5
      @doctype.render.should include tag
    end
    
    it 'indents to the view level' do
      @doctype.render
      @view.output.should match /^\W{4}<!DOCTYPE/
    end
  end
end
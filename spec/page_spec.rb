require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Garterbelt::Page do
  describe 'class level configuration' do
    class CustomPage < Garterbelt::Page
      self.doctype = :html5
      self.html_attributes = {:lang => "en",  "xml:lang" => "en"}
    end
    
    class NewCustom < CustomPage
    end
    
    
    describe 'doctype' do
      it 'defaults to :transitional' do
        Garterbelt::Page.doctype.should == :transitional
      end
      
      it 'can be customized' do
        CustomPage.doctype.should == :html5
      end
      
      it 'default is inherited' do
        NewCustom.doctype.should == :html5
      end
    end
    
    describe 'html_attributes' do
      it 'defaults to an empty hash' do
        Garterbelt::Page.html_attributes.should == {}
      end
      
      it 'can be customized' do
        CustomPage.html_attributes.should == {:lang => 'en', 'xml:lang' => 'en'}
      end
      
      it 'defaults are inherited' do
        NewCustom.html_attributes.should == {:lang => 'en', 'xml:lang' => 'en'}
      end
    end
  end
  
  it 'is a View' do
    BasicPage.new.is_a?(Garterbelt::View).should == true
  end
  
  describe 'rendering' do
    class BasicPage < Garterbelt::Page
      def head
        page_title "Basicly a Page"
      end
      
      def body
        p "Something should go here, yes?"
      end
    end
    
    class SpecificPage < Garterbelt::Page
      def body_attributes
        {:class => [:my_controller_class, :my_view_class], :id => :some_id}
      end
    end
    
    before do
      @view = MockView.new
      @view.level = 0
      @output = BasicPage.new.render
    end
    
    it 'makes a default doctype of :transitional' do
      @output.should include Garterbelt::Doctype.new(:type => :transitional, :view => @view).render
    end
    
    it 'wraps everything in html' do
      @output.should match /<html>/
    end
    
    it 'makes a head section' do
      @output.should match /<head>/
    end
    
    it 'renders the head content' do
      @output.should match /<title>\W*Basicly a Page\W*<\/title>/
    end
    
    it 'makes a body section' do
      @output.should match /<body>/
    end
    
    it 'adds the body attributes when defined' do
      SpecificPage.new.render.should include "<body class=\"my_controller_class my_view_class\" id=\"some_id\">"
    end
    
    it 'renders the body content' do
      @output.should match /<body>\W*<p>\W*Something should go here, yes\?\W*<\/p>\W*<\/body>/
    end
  end

end
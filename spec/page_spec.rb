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
      @view._level = 0
      @output = BasicPage.new.render
    end
    
    it 'clears the embedded files' do
      page = BasicPage.new
      page.embedded_files = ['foo.js', 'jar.css']
      page.render
      page.embedded_files.should == []
    end
    
    it 'renders the #page_content method' do
      page = BasicPage.new
      page.should_not_receive(:content).and_return('')
      page.should_receive(:page_content)
      page.render
    end
    
    it 'includes a default xml tag' do
      @output.should include Garterbelt::Xml.new(:view => @view, :type => :xml, :attributes => {:version => 1.0, :encoding => 'utf-8'}).render
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
  
  describe 'head content' do
    describe '#file' do
      it 'adds the file name to the embedded_files array'
      it 'returns an empty string if the file name is already in the array'
      it 'uses the class level directory to locate the file'
      it 'reads the file and returns the string'
    end
    
    describe '#embed_js' do
      describe 'strings' do
        it 'wraps a js string in the right script tag'
        it 'does not escape it'
      end
      
      describe 'an array with files and strings' do
      end
    end 
  end

end
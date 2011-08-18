require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# requiring the rails mocker and the rails module directly, now that Rails is mocked out
require File.expand_path(File.dirname(__FILE__) + "/rails_mocker")
require File.expand_path(File.dirname(__FILE__) + '/../lib/rails')

describe 'Garterbelt::Rails' do
  describe 'auto configuration' do
    it 'defines the Garterbelt::Rails module when Rails is defined' do
      defined?(Garterbelt::Rails).should be_true
    end
  
    it 'is configures rails to re-require templates via Rails' do
      Garterbelt::Rails::TemplateHandler.should_receive(:reload_templates)
      Garterbelt::Rails::Railtie.config.events.first.call
    end
    
    it 'add Garterbelt as a :rb view handler' do
      ActionView::Template.config.events.first.should == 
        "registered template handler #{[:rb, Garterbelt::Rails::TemplateHandler].inspect}"
    end
  end
  
  describe '::TemplateHandler' do
    before :all do
      defined?(Views).should be_false
      Garterbelt::Rails::TemplateHandler.reload_templates
    end
    
    describe 'klass extraction from path' do
      it 'should work' do
        identifier = Rails.root + '/app/views/thing/index.html.rb'
        Garterbelt::Rails::TemplateHandler.extract_class(identifier).should == 'Views::Thing::Index'
      end
    end
    
    describe '.reload_templates' do
      it 'builds the Views module' do
        defined?(Views).should be_true
      end
    
      it 'builds container modules' do
        defined?(Views::Thing).should be_true
      end
    
      it 'removes the Views constant before building' do
        Object.should_receive(:send).with(:remove_const, :Views)
        Garterbelt::Rails::TemplateHandler.reload_templates
      end
    
      it 'should re-evaluate the templates' do
        Garterbelt::Rails::TemplateHandler.reload_templates
        defined?(Views::Thing::Index).should be_true
      end
    end
  end
end

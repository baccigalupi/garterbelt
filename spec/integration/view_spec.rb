require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MarkupLounge::View, "Integration" do
  def file(name)
    File.read(File.dirname(__FILE__) + "/expectations/#{name}.html")
  end
  
  it 'views with tags should render and nest correctly' do
    ViewWithContentTags.new.render.should == file("view_with_tags")
  end
  
  describe 'variables' do
    it 'calls methods on passed objects' do
      user =  Hashie::Mash.new(:email => 'foo@example.com')
      ViewWithVars.new(:user => user).render.should == file('variables/view_with_user_email')
    end
    
    it 'uses optional params' do
      user =  Hashie::Mash.new(:name => 'foobar')
      ViewWithVars.new(:user => user, :params => {:remember_me => true}).render.should == file('variables/view_with_user_and_params')
    end
  end
end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::View, "Integration" do
  def file(name)
    File.read(File.dirname(__FILE__) + "/expectations/#{name}.html")
  end
  
  it 'views with tags should render and nest correctly' do
    ViewWithContentTags.new.render.should == file("view_with_tags")
  end
  
  it 'properly unescapes text' do
    format_text = "You should check out my rad new site:
      http://foo.com
      It will blow your mind!"
    UnescapingView.new(:format_text => format_text).render.should == file('unescaping_view')
  end
  
  it 'deals with textarea correctly' do
    FormWithTextarea.new.render.should == file('form_with_textarea')
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
  
  describe 'caching' do
    before do
      Garterbelt.cache.clear
      @user = Hashie::Mash.new(:id => 'foo_id', :upgradable? => true)
    end
    
    it 'renders it correctly the first time' do
      ViewWithCache.new(:user => @user).render.should == file('general_view')
    end
    
    it 'renders correctly from the cache' do
      ViewWithCache.new(:user => @user).render
      ViewWithCache.new(:user => @user).render.should == file("general_view")
    end
  end
  
  describe 'partials' do
    before do
      @user = Hashie::Mash.new(:id => 'foo_id', :upgradable? => true)
    end
    
    it 'render correctly with class arguments on the partial' do
      ViewWithPartial.new(:user => @user).render.should == file("general_view")
    end
    
    it 'renders correctly with a view instance' do
      ViewWithPartial2.new(:user => @user).render.should == file('general_view')
    end
    
    it 'nests deeply' do
      MyPagelet.new(:user => @user).render.should == file('view_partial_nest')
    end
    
    it 'works with passed blocks' do
      ViewWithForms.new.render.should == file('view_with_forms')
    end
  end
  
  describe 'render styles' do
    it 'does minified' do
      ViewWithContentTags.new.render(:style => :minified).should == file("render_styles/minified")
    end
    
    it 'does compact' do
      ViewWithContentTags.new.render(:style => :compact).should == file('render_styles/compact')
    end
    
    it 'does text only' do
      ViewWithContentTags.new.render(:style => :text).should == file("render_styles/text")
    end
    
    it 'styles do not screw up text line breaks, especially with raw text embeds' do
      PrettyWithEmbeds.new.render.should == file('render_styles/pretty_with_embeds')
    end
  end
end
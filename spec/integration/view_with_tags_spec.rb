require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

dir = File.dirname(__FILE__)
require dir + '/templates/view_with_tags'

describe "View with tags" do
  it 'should render correctly' do
    puts_hr ViewWithContentTags.new.render
    ViewWithContentTags.new.render.should == 
      File.read(dir + '/expectations/view_with_tags.html')
  end
end

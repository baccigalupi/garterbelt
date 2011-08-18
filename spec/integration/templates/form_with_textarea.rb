class FormWithTextarea < Garterbelt::View
  def content
    partial FormView, :class => 'texty', :action => '/go/textarea' do
      textarea 'foo', :name => 'my_text_area' 
    end
  end
end
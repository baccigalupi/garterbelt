class FormWithTextarea < Garterbelt::View
  def content
    partial FormView, :class => 'texty', :action => '/go/textarea' do
      textarea :name => 'my_text_area' do
        text 'foo'
      end
    end
  end
end
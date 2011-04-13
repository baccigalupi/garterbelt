class ViewWithForms < Garterbelt::View
  def content
    div :class => 'servey' do
      partial FormView, :action => '/form/fu' do
        label do
          h4 "Are you fu?"
          input :type => 'radio', :name => 'fu', :value => 'yes'
          text 'Yes!'
          input :type => 'radio', :name => 'fu', :value => 'no'
          text 'no :('
        end
        
        input :type => 'submit', :value => "Answer the Fu Master"
      end
      
      partial FormView, :action => '/user/info', :method => 'put', :class => 'update' do
        h4 "Provide us with updated information"
        label do
          text "Name: "
          input :type => 'text', :name => 'name'
        end
        
        label do
          text "Email: "
          input :type => 'text', :name => 'email'
        end
        input :type => 'submit', :value => 'Update'
      end 
    end
  end
end
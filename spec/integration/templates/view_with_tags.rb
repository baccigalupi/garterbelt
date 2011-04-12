class ViewWithContentTags < Garterbelt::View
  
  def content
    div.c(:line) do
      div.c(:unit, :size1of2) do
        h4 "Login"
        form :action => "/login", :class => :inner do
          label.c(:input) do
            text "Username or Email"
            input :name => 'login', :type => :text
          end
          
          label.c(:input) do
            text "Password"
            input :name => 'password', :type => :password
          end
          
          hr.c(:light)
          
          input :type => :submit, :value => "Login"
        end 
      end
    end
  end
  
end
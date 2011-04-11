class ViewWithVars < MarkupLounge::View
  needs :user, :params => {}
  
  def content
    div.c(:line) do
      div.c(:unit, :size1of2) do
        h4 "Login"
        form :action => "/login", :class => :inner do
          label.c(:input) do
            text "Username or Email"
            input :name => 'login', :type => :text, :value => user.email || user.name
          end
          
          label.c(:input) do
            text "Password"
            input :name => 'password', :type => :password
          end
          
          label.c(:remember_me) do
            text "Remember Me"
            input :name => 'remember_me', :type => :checkbox, :checked => params[:remember_me]
          end
          
          hr.c(:light)
          
          input :type => :submit, :value => "Login"
        end 
      end
    end
  end
  
end
class ViewWithContentTags < MarkupLounge::View
  
  def content
    div.c(:line) do
      div.c(:unit, :size1of2) do
        form :action => "/login", :class => :inner do
          label.c(:input) do
            text "Username or Email"
            input :name => 'login', :value => @user.login # type = text is default
          end
          
          label.c(:input) do
            text "password"
            input :name => 'login', :value => params[:password], :type => :password
          end
          
          hr.c(:light)
          
          label.c(:submit) do
            input :type => :submit, :value => "Login"
          end
        end 
      end
    end
  end
  
end
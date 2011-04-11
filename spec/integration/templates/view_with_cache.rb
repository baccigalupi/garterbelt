class ViewWithCache < MarkupLounge::View
  needs :user

  def content
    cache "user_#{user.id}" do
      div :class => "user_status" do
        ul do
          if user.upgradeable?
            li do
              a 'upgrade', :href => "#", :class => 'upgrade_link'
            end
          else
            li "pro", :class => 'pro', :title => "You're a real pro."
          end
          
          li do
            a 'settings', :href => "/user/#{user.id}?selected=settings",
              :id => "settings_link",
              :title => "Reset your name or password, upload your photo, or adjust your email notifications"
          end
          
          li :class => 'last' do
            a "logout", :href => "/logout", :title => "Get out of here!", :class => 'logout_link'
          end
        end
      end
    end
  end
  
end
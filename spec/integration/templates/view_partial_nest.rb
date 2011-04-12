class MyPagelet < Garterbelt::View
  needs :user
  
  def content
    body.c(:my_pagelet) do
      partial Header, :user => user
      div.id(:wrapper) do
        text 'my page here'
      end
    end
  end
end

class Header < Garterbelt::View
  needs :user
  
  def content
    div.id(:header) do
      partial ViewWithPartial, :user => user
    end
  end
end
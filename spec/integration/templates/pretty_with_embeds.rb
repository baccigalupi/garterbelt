class PrettyWithEmbeds < Garterbelt::Page
  def head
    script 'type' => 'text/javascript' do
      [
        'alert("foo");',
        "alert(\"bar\");\nvar foo = 'foo';"
      ].each do |js|
        raw_text js
      end
    end
    
    style 'type' => 'text/css' do
      [
        "body { background-color: blue; color: white; border: 1px solid black; margin: 1em auto; padding: 2em; /* then a long comment that extends for a while, this should not get split up, thanks! */ }",
        "p { background-color: white;}"
      ].each do |css|
        raw_text css
      end
    end
  end
  
  def body
    p "Style me up!"
  end
end
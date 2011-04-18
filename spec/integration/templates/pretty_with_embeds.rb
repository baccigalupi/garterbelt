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
        "body { background-color: blue;}",
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
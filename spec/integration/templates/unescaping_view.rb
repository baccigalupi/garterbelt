class UnescapingView < Garterbelt::View
  requires :format_text
  
  def content
    format_text.gsub!(/<[^>]*>/, '')
    format_text.gsub!(/\b((https?|mailto):(\/\/)?\S+)/, "<a class=\"user_generated_link\" href=\"\\1\">\\1</a>")
    format_text.gsub!("\n", "<br>\n")
    format_text.gsub!(/ {2,1000}/, '')
    
    raw_text format_text
  end
end
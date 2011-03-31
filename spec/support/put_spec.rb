require 'cgi'
module PutSpec
  def putspec message
    puts CGI.escapeHTML("#{message.inspect}") if message
  end
  
  def hr
    puts "<hr>"
  end
end
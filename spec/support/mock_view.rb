class MockView
  attr_accessor :output, :buffer, :level, :escape
  
  def initialize
    self.buffer = []
    self.output = ""
    self.level ||= 2
    self.escape = true
  end
  
  def render_buffer
  end
end
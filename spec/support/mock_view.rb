class MockView
  attr_accessor :output, :buffer, :level, :escape, :cache
  
  def initialize
    self.buffer = []
    self.output = ""
    self.level ||= 2
    self.escape = true
    self.cache = Moneta::Memory.new
  end
  
  def render_buffer
  end
end
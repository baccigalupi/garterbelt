class MockView
  attr_accessor :output, :buffer, :level, :escape, :cache_store
  
  def initialize
    self.buffer = []
    self.output = ""
    self.level ||= 2
    self.escape = true
    self.cache_store = Moneta::Memory.new
  end
  
  def render_buffer
  end
end
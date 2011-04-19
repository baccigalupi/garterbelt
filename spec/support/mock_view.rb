class MockView
  attr_accessor :output, :buffer, :_level, :escape, :cache_store, :render_style
  
  def initialize
    self.buffer = []
    self.output = ""
    self._level ||= 2
    self.escape = true
    self.render_style = :pretty
    self.cache_store = Moneta::Memory.new
  end
  
  def render_buffer
  end
end
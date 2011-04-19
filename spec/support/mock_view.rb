class MockView
  attr_accessor :output, :_buffer, :_level, :_escape, :cache_store, :render_style
  
  def initialize
    self._buffer = []
    self.output = ""
    self._level ||= 2
    self._escape = true
    self.render_style = :pretty
    self.cache_store = Moneta::Memory.new
  end
  
  def render_buffer
  end
end
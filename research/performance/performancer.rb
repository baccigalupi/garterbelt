class Performancer
  def self.measurements
    @measurements ||= []
  end
  
  def perform
    # do nothing
  end
  
  def performerate
    start = Time.now
    perform
    measurements << Time.now - start
  end
  
  def measurements
    self.class.measurements
  end
  
  def self.measure(times=100)
    measurements.clear
    instance = new
    (1..times).each { instance.performerate }
    message
  end
  
  def self.message
    size = measurements.size 
    max = measurements.max
    min = measurements.min
    sum = measurements.reduce(0) {|sum, value| sum + value }
    "# #{self} #{Time.now.strftime('%m/%d/%Y %H:%M')} | #{size} runs: average=#{sum/size.to_f}; max=#{max}; min=#{min}"
  end 
end

Performancer.measure
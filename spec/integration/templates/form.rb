class FormView < Garterbelt::View
  requires :method => :get
  
  def initialize(options, &block)
    super
    self.method = method.to_s.downcase
  end
  
  def content
    form form_options do
      if legal_method != method
        input :type => 'hidden', :name => "_method", :value => method
      end  
        
      block.call if block
    end
  end
  
  def form_options
    initialization_options.merge(:method => legal_method)
  end
  
  def legal_method
    if ['get', 'post'].include?( method )
      method
    else
      'post'
    end 
  end
end
require 'rack/throttle'

class Throttler < Rack::Throttle::Interval
  
  def initialize(app, options = {})
    super
  end
     
  def allowed?(request)
    if request.path_info =~ /\/plink$/
      super(request)
    else
      true
    end
  end
end
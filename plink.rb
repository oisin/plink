$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'sinatra'
require 'sinatra/mongomapper'

set :mongomapper, 'mongomapper://localhost:27017/plink_trail_' + ENV['RACK_ENV']
set :mongo_logfile, File.join("log", "mongo-driver-#{ENV['RACK_ENV']}.log")
set :show_exceptions, false

MAJOR_VERSION = 1
MINOR_VERSION = 3
VERSION_REGEX = %r{/api/v(\d)\.(\d)}

require 'plinkmodels'

# Return track data on the given handset
#
get '/track/:handset' do
  h = Handset.where(:code => params[:handset]).first
  if h
    200
  else
    [404, 'Handset not registered']
  end
end

# Post an update to the handset's location
# trail
#
post '/plink' do
  puts "++++++++++++ PLINK"
  501
end

# Register the handset, plus DNA, assign an
# identifier we will use
#
put '/register' do
  payload = request.body.read
  if payload
    # Payload contains the 'DNA' identification
    # for the phone. It is a dictionary, which we
    # serialize to text and store. It's also used
    # to make a code for the handset.
    #
    code = Digest::SHA512.hexdigest("#{payload}")
    h = Handset.where(:code => code).first
    if !h
      h = Handset.create(:status => 'registered', :code => code)
      h.save
    end
    code
  else
    [400, 'Cannot register handset']
  end
end

delete '/:handset' do
  hid = Handset.where(:code => params[:handset]).first
  Handset.delete(hid._id) if hid
  200
end

helpers do
  def version_compatible?(nums)
    return MAJOR_VERSION == nums[0].to_i && MINOR_VERSION >= nums[1].to_i
  end
end

before VERSION_REGEX do
  if version_compatible?(params[:captures])
    request.path_info = request.path_info.match(VERSION_REGEX).post_match
  else
    halt 400, "Version not compatible with this server"
  end
end


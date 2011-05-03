$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'sinatra'
require 'sinatra/mongomapper'

set :mongomapper, 'mongomapper://localhost:27017/plink_trail'
set :mongo_logfile, File.join("log", "mongo-driver-#{ENV['RACK_ENV']}.log")

MAJOR_VERSION = 1
MINOR_VERSION = 3

require 'plinkmodels'

# Return track data on the given handset
#
get '/track' do
  puts "++++++++++++ TRACK"
  200
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
    # to make an ID for the handset.
    #
    puts "#{payload}"
    salt = random_salt
    h = Handset.create(:salt => salt, :status => 'registered', :id => Digest::SHA512.hexdigest("#{payload}:#{salt}"))
    h.save
    h.id
    200
  else
    400
  end
end

delete '/:handset' do
  puts "++++++++++++ DEL"
  501
end

helpers do
  def version_compatible?(nums)
    return MAJOR_VERSION == nums[0].to_i && MINOR_VERSION >= nums[1].to_i
  end
  
  def random_salt
    chars = []
    64.times { chars << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    chars.join
  end
end

before %r{/api/v(\d)\.(\d)} do
  if version_compatible?(params[:captures])
    target = request.fullpath.split('/').last
    request.path_info = "/#{target}"
  else
    halt 400, "Version not compatible with this server"
  end
end


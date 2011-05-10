$:.unshift File.join(File.expand_path(File.dirname(__FILE__)))

require 'sinatra/base'
require 'mongo_mapper'
require 'memcached'
require 'rack/throttle'

require 'plinkmodels'
require 'throttler'

class PlinkApp < Sinatra::Base
  set :show_exceptions, false

  MAJOR_VERSION = 1
  MINOR_VERSION = 3
  VERSION_REGEX = %r{/api/v(\d)\.(\d)}
  MAX_LOCATIONS = 12 * 24 * 90   # 12 per hour, 24 hours a day, for 90 days

  configure :production do
    use Throttler, :min => 300.0, :cache => Memcached.new, :key_prefix => :throttle
  end
  
  configure do
    if ENV['MONGOHQ_URL']
      puts "Running on MongoHQ" 
      uri = URI.parse(ENV['MONGOHQ_URL'])
      MongoMapper.connection = Mongo::Connection.(uri.host, uri.port)
      MongoMapper.database = uri.path.gsub(/^\//, '')
      MongoMapper.database.authenticate(uri.user, uri.password)
    else
      puts "Using local database" 
      MongoMapper.connection = Mongo::Connection.new("localhost", 27017)
      MongoMapper.database = "plink_trail_" + ENV['RACK_ENV']
    end

    Handset.ensure_index(:code)
  end

  # Post an update to the handset's location
  # trail
  #
  post '/plink' do
    payload = request.body.read
    if payload
      data = JSON.parse(payload)
      h = Handset.find_by_code(data['handset'])
      if h
        location = Location.new(:time => DateTime.now)

        %w{handset lat long}.each do |item|
          halt 400, "Missing #{item} datum" unless data["#{item}"]
          location["#{item}"] = data["#{item}"]
        end

        %w{accu alt}.each do |item|
          location["#{item}"] = data["#{item}"]
        end
        h.locations << location
        if h.locations.count > MAX_LOCATIONS
          h.locations.shift
        end
        h.save
        200
      else
        [404, "No handset with that identification is registered"]
      end
    else
      [400, "No location data provided"]
    end
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
      [400, 'No handset data provided']
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
end

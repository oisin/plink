require 'sinatra/base'
require 'mongo_mapper'
require 'erb'

class TrackApp < Sinatra::Base
  set :show_exceptions, false
  set :views, File.join(File.dirname(__FILE__), 'views/track')
  set :public, File.join(File.dirname(__FILE__), 'public/track')
  
  configure {
    if ENV['MONGOHQ_URL']
      puts "Running on MongoHQ" 
      uri = URI.parse(ENV['MONGOHQ_URL'])
      MongoMapper.connection = Mongo::Connection.new(uri.host, uri.port)
      MongoMapper.database = uri.path.gsub(/^\//, '')
      MongoMapper.database.authenticate(uri.user, uri.password)
    else
      puts "Using local database" 
      MongoMapper.connection = Mongo::Connection.new("localhost", 27017)
      MongoMapper.database = "plink_trail_" + ENV['RACK_ENV']
    end

    Handset.ensure_index(:code)
  }

  not_found { erb :'404'}

  get '/handsets' do
    @handsets = Handset.all
    erb :index
  end
  
  get '/:handset' do
    @handset = Handset.find_by_code(params[:handset])
    if @handset
      erb :handset
    else
      raise Sinatra::NotFound
    end
  end
end

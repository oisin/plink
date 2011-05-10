require 'sinatra/base'
require 'mongo_mapper'
require 'erb'

class TrackApp < Sinatra::Base
  set :show_exceptions, false
  set :views, File.join(File.dirname(__FILE__), 'views/track')
  set :public, File.join(File.dirname(__FILE__), 'public/track')
  
  configure {
    MongoMapper.connection = Mongo::Connection.new("localhost", 27017)
    MongoMapper.database = "plink_trail_" + ENV['RACK_ENV']
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

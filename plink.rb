require 'sinatra'
require 'rack/throttle'

config do
end

helpers do
end

post '/api/v[\d\.\d]/plink'
end

get '/api/v[\d\.\d]/track'
end

put '/api/v[\d\.\d]/register'
end

del '/api/v[\d\.\d]/:handset'
end


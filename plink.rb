require 'sinatra'

get '/track' do
  puts "++++++++++++ TRACK"
  501
end

post '/plink' do
  puts "++++++++++++ PLINK"
  501
end

put '/register' do
  puts "++++++++++++ REG"
  501
end

delete '/:handset' do
  puts "++++++++++++ DEL"
  501
end

configure do
  MAJOR_VERSION = 1
  MINOR_VERSION = 0
end

helpers do
  def version_compatible?(nums)
    return MAJOR_VERSION == nums[0].to_i && MINOR_VERSION >= nums[1].to_i
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


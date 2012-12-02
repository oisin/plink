$:<<::File.dirname(__FILE__)

require 'plink'
require 'track'

map "/track" do
  run TrackApp
end

map "/" do
  run PlinkApp
end

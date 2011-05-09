class Handset
  include MongoMapper::Document

  key :code, String, :required => true
  key :status, String, :required => true
  many :locations

  timestamps!
  
end


class Location
  include MongoMapper::EmbeddedDocument
  
  key :lat, Float, :required => true
  key :long, Float, :required => true
  key :alt, Float
  key :accuracy, Float
  key :time, DateTime, :required => true
  
  attr_protected :time
end

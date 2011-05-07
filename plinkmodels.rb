class Handset
  include MongoMapper::Document

  key :code, String
  key :salt, String
  key :status, String
  many :locations

  timestamps!
end


class Location
  include MongoMapper::EmbeddedDocument
  
  key :lat, Float
  key :long, Float
  key :alt, Float
  key :accuracy, Float
  key :time, DateTime
end

class Location < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :name, :zipcode
end

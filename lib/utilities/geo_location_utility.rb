#
# include Utilities::GeoLocationUtility
#
# To use the utilty in controller, use the above command to include.

module Utilities
  module GeoLocationUtility
    class MethodNotImplementedError < StandardError ; end

    @@DISTANCE = { mi: 3956, km: 6371 }

    # Need to change this method to return all co-ordinates/zipcodes in range to the given zip code.
    #
    #  Reference -
    # http://stackoverflow.com/questions/3552334/finding-a-set-of-coordinates-within-a-certain-range-from-latitude-longitide
    def find_ordinates_in_range(zipcode, miles)

      coordinate_result_set = []

      coordinates = get_coordinates(zipcode)

      #Refer:http://www.techraza.com/other/search-around-a-particular-latitude-and-longitude-by-a-given-radius/
      range = miles / 70.00

      min_lat = coordinates[0].to_f - range
      max_lat = coordinates[0].to_f + range

      min_lng = coordinates[1].to_f - range
      max_lng = coordinates[1].to_f + range

      lat_key = SecureRandom.hex(10)
      lng_key = SecureRandom.hex(10)
=begin
key = SecureRandom.hex(10)

      r = Redis.current

      r.multi do

        r.zunionstore(lat_key, ["user_profile::sorted_latitudes"])
        r.zremrangebyscore(lat_key, -90, min_lat.to_s)
        r.zremrangebyscore(lat_key, max_lat.to_s, 90)

        r.zunionstore(lng_key, ["user_profile::sorted_longitudes"])
        r.zremrangebyscore(lng_key, -180, min_lng.to_s)
        r.zremrangebyscore(lng_key, max_lng.to_s, 180)

        coordinate_result_set << lat_key
        coordinate_result_set << lng_key

        r.zinterstore(key, coordinate_result_set)

      end

      return key
=end

    end

    # Calculates distance between two points.
    # Each point is an Array of latitude-longitude.
    # @param origin Array
    # @param destination Array
    # @param type This can be ':mi' or ':km'
    def calculate_distance(origin,destination, type=:mi)
      radius = @@DISTANCE[type]
      source_lat = to_rad(origin[0])
      destination_lat = to_rad(destination[0])

      source_ln = to_rad(origin[1])
      destination_ln = to_rad(destination[1])

      dLat = destination_lat-source_lat
      dLon = destination_ln-source_ln

      a = Math::sin(dLat/2) * Math::sin(dLat/2) +
          Math::cos(source_lat) * Math::cos(destination_lat) *
              Math::sin(dLon/2) * Math::sin(dLon/2)
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
      (radius * c).to_i
    end

    def calculate_distance_from_zipcode(zipcode,destination)
      calculate_distance(get_coordinates(zipcode),destination).to_i
    end

    def calculate_distance_between_zipcodes(src_zip,dest_zip)
      calculate_distance(get_coordinates(src_zip),get_coordinates(dest_zip)).to_i
    end

    def get_coordinates(zipcode)
      coordinates = []
      begin
        res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{zipcode}"
        @lat = res.lat
        @lng = res.lng
      rescue
        @lat = -1.0
        @lng = -1.0
      end

      coordinates << @lat
      coordinates << @lng

    end

    def is_valid_usa_zipcode?(zipcode)
      is_valid = true
      begin
        res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{zipcode}"
        if res.country != "USA"
          is_valid = false
          @msz = I18n.t 'errors.messages.not_belongs_usa'
        else
          is_valid = true
          @state = res.state
          @city = res.city
        end
      rescue
        is_valid = false
        @msz = I18n.t 'errors.messages.not_valid_zipcode'
      end
      return is_valid
    end

    private

    def to_rad angle
      (Math::PI/180) * angle.to_f
    end

  end
end
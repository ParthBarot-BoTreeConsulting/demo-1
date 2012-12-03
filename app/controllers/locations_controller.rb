class LocationsController < ApplicationController
  def find
    coordinates = []
    latitude_range = []
    longitude_range = []
    @addresses = []

    zipcode = params[:zipcode]
    range = params[:range]

    coordinates = get_coordinates(zipcode)

    if coordinates[0] == -1 || coordinates[1] == -1
      flash[:error] = "The Zip entered is an Invalid US Zipcode."
    end

    latitude_range << coordinates[0].to_i - range.to_i / 70
    latitude_range << coordinates[0].to_i + range.to_i / 70

    longitude_range << coordinates[1].to_i - range.to_i / 70
    longitude_range << coordinates[1].to_i + range.to_i / 70

    (latitude_range[0]..latitude_range[1]).each do |latitude|
      (longitude_range[0]..longitude_range[1]).each do |longitude|
        address = get_address(latitude, longitude)
        if address.present?
           @addresses << address
        end
      end
    end

    return @addresses
  end

  def get_address(latitude, longitude)
    res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{latitude}, #{longitude}"
    address = res.city.to_s + ", " + res.state.to_s + ", " + res.zip.to_s if res.city.present? && res.state.present? && res.zip.present?
  end

  def get_coordinates(zipcode)
    coordinates = []
    res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode "#{zipcode}"

    if res.country != "USA"
      @lat = -1
      @lng = -1
    else
      @lat = res.lat
      @lng = res.lng
    end

    coordinates << @lat
    coordinates << @lng

  end

end

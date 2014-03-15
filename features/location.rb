require 'helper'

describe 'Basic features' do
  attr_reader :cs

  before do
    @cs = new_cs
  end

  it 'Gets location by name' do
    vcr do
      name = 'New York'
      cs.sign_in
      locations = cs.find_location name
      city_names = locations.map { |location| location.city }
      assert_includes city_names, name
    end
  end
end

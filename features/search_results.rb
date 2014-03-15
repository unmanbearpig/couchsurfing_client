require 'helper'

module CouchSurfingClient
  class TestSearchResults < Minitest::Test
    attr_reader :cs, :location

    TEST_CITY = {
      'city_id' => 1597093,
      'state_id' => 5284,
      'country_id' => 202,
      'region_id' => 6,
      'longitude' => 30.264165231165,
      'latitude' => 59.89444109603,
      'population' => 7341,
      'population_dimension' => 3,
      'has_couchrequest' => 1,
      'city' => 'Saint Petersburg',
      'state' => 'Saint Petersburg',
      'country' => 'Russia',
      'region' => 'Europe',
      'type' => 'city'
    }

    def setup
      @cs = new_cs
      @location = Location.new @cs, TEST_CITY
    end

    def test_search_gets_a_few_items
      vcr do
        cs.sign_in
        items_to_get = 10
        result = location.search.locals.get(items_to_get)
        assert_operator result.count, :>=, items_to_get
      end
    end

    def test_search_gets_more_items
      vcr do
        cs.sign_in
        items_to_get = 23
        result = location.search.locals.get(items_to_get)
        assert_operator result.count, :>=, items_to_get
      end
    end

    def test_search_has_no_duplicates
      vcr do
        cs.sign_in

        items_to_get = 23
        result = location.search.locals.get(items_to_get)

        assert_equal result.user_ids.length, result.user_ids.uniq.length
      end
    end

    def test_not_more_than_one_surfer_from_the_city_in_that_city
      vcr do
        cs.sign_in

        items_to_get = 20

        result = location.search.surfers.get(items_to_get)

        refute_includes result.items.map { |item| item.couch_request? }, false, 'There are not only couch requests among found surfers'

        number_of_surfers_in_hometown = result.items.select { |item| item.lives_in.include? location.city }.length

        assert_operator number_of_surfers_in_hometown, :<=, 1, 'too many people surf in their hometown, probably our search does not work properly'
      end
    end

    def test_get_all_search_results
      vcr do
        cs.sign_in

        results = location.search.surfers.female.several_people.from_age(20).get

        actual_items = results.items.map { |item| item.profile_id }

        expected_items = results.pages.map do |page|
          page.items.map { |item| item.profile_id }
        end.flatten

        assert_equal expected_items, actual_items, 'result items should be equal to list of all pages items'
      end
    end
  end
end

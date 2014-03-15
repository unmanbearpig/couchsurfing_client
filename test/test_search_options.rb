require 'test_helper'

module CouchSurfingClient
  describe 'SearchQuery' do
    attr_reader :query, :valid_query

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

    def assert_these_params expected_params, search_query, msg = nil
      actual_search_params = search_query.to_h.select { |k, v| expected_params.keys.include? k }

      assert_equal expected_params, actual_search_params, msg
    end

    before do
      @query = SearchQuery.new nil
      @valid_query = SearchQuery.new(nil).location(Location.new(nil, TEST_CITY)).locals
    end

    describe 'Verifications' do
      it 'Raises error if location is missing' do
        assert_raises MissingSearchParameterError do
          query.surfers.result
        end
      end

      it 'Raises error if search type is missing' do
        assert_raises MissingSearchParameterError do
          query.location({}).result
        end
      end

      it 'Raises error if order is invalid' do
        assert_raises InvalidSearchParameterError do
          valid_query.order_by(:test).result
        end
      end

      it 'Raises exception if invalid param passed to it' do
        assert_raises InvalidSearchParameterError do
          valid_query.where test: 'blah'
        end
      end
    end

    describe 'Gender' do
      def assert_genders genders, query
        expected_genders = {
          'male' => genders.include?(:male) ? '1' : '0',
          'female' => genders.include?(:female) ? '1' : '0',
          'several_people' => genders.include?(:several_people) ? '1' : '0'
        }

        actual_genders = query.to_h.select { |k, v| expected_genders.keys.include? k }

        assert_equal expected_genders, actual_genders
      end

      it 'Returns all genders by default' do
        assert_genders [:male, :female, :several_people], valid_query
      end

      it 'Returns only males if male was specified' do
        assert_genders [:male], valid_query.male
      end

      it 'Returns only genders that were specified' do
        assert_genders [:female, :several_people], valid_query.female.several_people
      end
    end

    it 'Does not crash if query is correct' do
      valid_query.result
    end

    it 'Adds default params to result hash' do
      defaults = {
        'search' => 'Search!',
        'submit_button' => 'search',
        'submitted' => 'manual',
        'surfer_end_at_format' => '%m/%d/%Y',
        'surfer_end_at_tzo' => '0',
        'surfer_start_at_format' => '%m/%d/%Y',
        'surfer_start_at_tzo' => '0',
        'type' => 'user',
        'which_groups' => 'A',
        'zoom_level' => '',
        'polygon' => '',
        'map_edges' => '',
        'age_high' => '',
        'age_low' => '',
        'female' => '1',
        'male' => '1',
        'several_people' => '1',
        'keyword' => '',
        'language_id' => '',
        'last_login_days' => '',
        'order_by' => 'default'
      }

      assert_these_params defaults, valid_query
    end

    it 'Sets age parameters' do
      expected_params = {
        'age_high' => '32',
        'age_low' => '26'
      }

      assert_these_params expected_params, valid_query.from_age(26).to_age(32)
    end

    it 'Can get a location' do
      assert_kind_of Location, valid_query.location
      assert_equal TEST_CITY['city_id'], valid_query.location.city_id
    end
  end
end

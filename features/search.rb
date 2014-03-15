require 'helper'

describe 'Searching' do
  attr_reader :location, :cs

  before do
    vcr do
      @cs = new_cs
      @location = cs.find_location('Barcelona').first
    end
  end

  describe 'Parameters verification' do
    it 'Fails if location is missing' do
      assert_raises CouchSurfingClient::MissingSearchParameterError do
        cs.search.locals.get 10
      end
    end

    it 'Fails if search_mode is missing' do
      assert_raises CouchSurfingClient::MissingSearchParameterError do
        location.search.get 10
      end
    end

    it 'Fails if order_by parameter is invalid' do
      assert_raises CouchSurfingClient::InvalidSearchParameterError do
        location.search.locals.order_by(:test).get 10
      end
    end

    it 'Fails if both username and search_mode are defined' do
      assert_raises CouchSurfingClient::InvalidSearchParameterError do
        location.search.username('test').surfers.get 10
      end
    end
  end

  it 'Fetches user profile by search_item.get_profile' do
    vcr do
      search_results = location.search.locals.get 1
      profile = search_results.first.get_profile

      assert profile
      assert_kind_of CouchSurfingClient::Profile, profile
      assert_kind_of String, profile.name
    end
  end

  describe 'Results sanity' do
    def assert_each_search_item search_results, msg
      failed_items = search_results.reject do |item|
        yield item
      end.map { |item| item.to_s }

      assert_equal [], failed_items, "#{failed_items.count} out of #{search_results.count} #{msg}"
    end

    describe 'Search modes' do
      def assert_live_in location, search_results, msg
        assert_each_search_item search_results, msg do |item|
          item.lives_in.include? location.city
        end
      end

      def refute_live_in location, search_results, msg
        assert_each_search_item search_results, msg do |item|
          !item.lives_in.include? location.city
        end
      end

      it 'Returns locals when searched for locals' do
        vcr do
          location.cs.sign_in
          search_results = location.search.locals.get 20
          assert_operator search_results.count, :>, 0

          assert_live_in location, search_results, "locals don't live in the city #{location}"
        end
      end

      it 'Returns not locals when searched for surfers' do
        vcr do
          location.cs.sign_in
          search_results = location.search.surfers.get 20
          assert_operator search_results.count, :>, 0

          refute_live_in location, search_results, "surfers live in the city they surf in (#{location})"
        end
      end

      it 'Returns locals when searched for hosts' do
        vcr do
          location.cs.sign_in

          search_results = location.search.hosts.get 20
          assert_operator search_results.count, :>, 0

          assert_live_in location, search_results, "hosts don't live in that city (#{location})"
        end
      end

      it 'Returns foreigners when searched for travellers' do
        vcr do
          location.cs.sign_in

          search_results = location.search.travellers.get 20
          assert_operator search_results.count, :>, 0

          refute_live_in location, search_results, "travellers live in than location (#{location})"
        end
      end
    end

    describe 'Gender' do
      def assert_genders gender_syms, search_results
        genders = gender_syms.map { |sym| CouchSurfingClient::Gender.new sym }
        msg = "items have wrong gender (expected #{genders.map(&:to_s).join(', ')})"
        assert_each_search_item search_results, msg do |item|
          genders.include? item.gender
        end
      end

      it 'Returns males when searched for males' do
        vcr do
          assert_genders [:male], location.search.locals.female.get(20)
        end
      end

      it 'Returns females when searched for females' do
        vcr do
          assert_genders [:female], location.search.locals.female.get(20)
        end
      end

      it 'Returns several people when searched for several people' do
        vcr do
          assert_genders [:several_people], location.search.locals.several_people.get(20)
        end
      end

      it 'Returns not males when searched for not males' do
        vcr do
          assert_genders [:female, :several_people], location.search.locals.female.several_people.get(20)
        end
      end
    end

    it 'Returns couch requests when searched for surfers' do
      vcr do
        location.cs.sign_in

        search_results = location.search.surfers.get 20
        assert_operator search_results.count, :>, 0

        assert_each_search_item search_results, 'items are not couch_requests' do |item|
          item.couch_request?
        end
      end
    end

    it 'Returns people of searched age' do
      vcr do
        location.cs.sign_in

        from_age = 25
        to_age = 32
        search_results = location.search.locals.from_age(from_age).to_age(to_age).get 20
        assert_operator search_results.count, :>, 0

        assert_each_search_item search_results, 'people are different age than specified' do |item|
          item.age >= from_age && item.age <= to_age
        end
      end
    end

    # TODO
    it 'Finds by username'
    it 'Searches for keyword and returns people with the keyword in profile'

    it 'Returns at least specified number of results'
    it 'Returns no duplicates'
  end
end

# -*- coding: utf-8 -*-
require 'test_helper'

module CouchSurfingClient
  class TestSmoke < Minitest::Test
    def test_parse_location_suggest
      location_suggest_output = get_asset 'location_suggest.asset'
      expected = get_yaml_asset 'location_suggest_parsed.yaml'

      actual = LocationSuggestParser.new location_suggest_output

      assert_equal expected, actual.to_a
    end
  end
end

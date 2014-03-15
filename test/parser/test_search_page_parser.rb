require 'test_helper'

module CouchSurfingClient
  class TestSearchPageParser < Minitest::Test
    attr_reader :text, :parser

    def setup
      @text = get_asset 'search_result.asset'
      @parser = SearchPageParser.new text
    end

    def test_number_of_items
      assert_equal 10, parser.count
    end
  end
end

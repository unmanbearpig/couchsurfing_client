# -*- coding: utf-8 -*-
require 'test_helper'

module CouchSurfingClient
  class TestFriendsParser < Minitest::Test
    attr_reader :html, :parser

    def setup
      @html = get_asset 'friends.html'
      @parser = FriendsParser.new html
    end

    def test_smoke
      assert_equal 4, parser.to_a.count
    end

    def test_all_keys_present
      parser.to_a.each do |friend|
        friend.keys.each do |key|
          refute_equal nil, friend.send(key)
        end
      end
    end
  end
end

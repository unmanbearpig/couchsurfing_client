# -*- coding: utf-8 -*-
require 'test_helper'

module CouchSurfingClient
  class TestSearchItem < Minitest::Test
    attr_reader :html, :parser, :couch_request_html, :couch_request_parser

    def setup
      @html = get_asset 'search_result_item.html'
      @parser = SearchItemParser.new html

      @couch_request_html = get_asset 'couch_request_search_item.html'
      @couch_request_parser = SearchItemParser.new couch_request_html
    end

    def test_smoke
      assert_kind_of Hash, parser.to_h
    end

    def test_all_keys_present
      missing_keys = parser.keys.reject { |key| parser.send(key) }
      assert_equal [], missing_keys, 'There are keys that haven\'t been parsed'
    end

    def test_result
      expected_hash = {
        name: 'Lio Leo',
        href: '/profile.html?id=5HCBAGPKF&from_search&search_ranking_locals=1',
        profile_id: '5HCBAGPKF',
        profile_pic: 'https://s3.amazonaws.com/images.couchsurfing.us/5HCBAGPKF/23998551_m_a9e353d64daabfed49e23d7013fb955e.jpg',
        gender: 'Male',
        age: 111,
        occupation: 'Song writer/Musician',
        mission: 'I am on the way to make a long break of travel around the world&Open my own Jazz/Bossa Nova Lounge Club&Try my best to be happy with the rest of the world!!',
        about: %q{We can't be afraid of change. You may feel very secure in the pond that your are in, but if you never venture out of it, you will never know that there is such a thing as an ocean, a sea. Holding onto something that is good for you now, may be the very reason why you don't have something better.Take fears out of you heart,mind,feelings and start to make change at you life where you never imagine that could be possible!},
        lives_in: 'Amsterdam, Noord-Holland, Netherlands',
        last_in_location: 'St Petersburg, St Petersburg, Russian Federation',
        last_in_time: '3 hours ago',
        friends_count: 12,
        references_count: 12,
        photos_count: 12,
        languages: {
          'Portuguese (Brazil)' => 'exp',
          'Spanish' => 'exp',
          'German' => 'exp',
          'English' => 'exp',
          'French' => 'int'
        }
      }

      assert_equal expected_hash, parser.to_h
    end

    def test_search_item_recognizes_couch_request
      assert couch_request_parser.is_couch_request, 'search item expected to be a couch request'
    end

    def test_search_item_parses_all_couch_request_keys
      missing_keys = couch_request_parser.couch_request_keys
        .select { |key| couch_request_parser.send(key).nil? }
      assert_equal [], missing_keys, 'There are not parsed couch request keys'
    end

    def test_search_item_parses_couch_request_properly
      expected_hash = {
        about: 'Мне 23 года. Живу в Калининграде и работаю медсестрой в стоматологии. Мое хобби и увлечение всей моей жизни -тату! Грежу о том, чтобы стать профессионалом и путешествовать по миру,заезжая в разные тату салоны и обмениваясь опытом)) Очень люблю путешествовать. Хотя бы раз в год не выехать куда-нить это огромная потеря для меня.I am 23 years. Live in Kaliningrad and work as a nurse in dentistry. My hobby and passion of my life tattoo! Dreaming about how to become a pro and travel the world, stopping in different tattoo parlors and sharing experiences)) Love to travel. At least once a year (...)',
        age: 23,
        arrival_date: '2014-04-21',
        city_couchrequest_id: '2615099',
        couch_request_city: 'Saint Petersburg, Saint Petersburg, Russia',
        departure_date: '2014-05-08',
        friends_count: 0,
        gender: 'Female',
        href: '/profile.html?id=5HSSBCK05&city_couchrequest=2615099&from_search&search_ranking_surfers=1',
        languages: {
          'English' => 'int',
          'Russian' => 'exp'
        },
        last_in_location: 'Kaliningrad, Kaliningradskaya oblast, Russia',
        last_in_time: '1 hour ago',
        lives_in: 'Kaliningrad, Russia',
        mission: 'I want stay tatto-master and treval all word and make tattoo ^__^',
        name: 'Kira Sudakova',
        number_of_surfers: 1,
        occupation: 'Work, draw, treval',
        open_request: 'Привет! Я из Калининград. Я планирую приехать в Питер с 21 апреля по 8 мая, для того чтобы пройти обучение в тату салоне. Очень бедна финансово, но богата внутренне) Если у кого есть возможность приютить на 1-2-3 недели....прогулки по Питеру, теплые вечера и непринужденные беседы...очень аккуратна, буквально до чистоплюйства....могу гарантировать всем желающим бесплатные тату))',
        photos_count: 3,
        profile_id: '5HSSBCK05',
        profile_pic: 'https://s3.amazonaws.com/images.couchsurfing.us/5HSSBCK05/25610816_m_5d06d0252581ff3c87392df79e6dbc13.jpg',
        references_count: 0
      }

      assert_equal expected_hash, couch_request_parser.to_h
    end
  end
end

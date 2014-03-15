require 'json'
require 'net/http'
require 'logger'
require 'nokogiri'
require 'mechanize'
require 'yaml'
require 'English'

require 'couchsurfing_client/log_helper'
require 'couchsurfing_client/exceptions'
require 'couchsurfing_client/parser'
require 'couchsurfing_client/sign_in_page'
require 'couchsurfing_client/cs_connector'
require 'couchsurfing_client/search_query'
require 'couchsurfing_client/search_item'
require 'couchsurfing_client/search_page'
require 'couchsurfing_client/search_results'
require 'couchsurfing_client/version'

module CouchSurfingClient
  class CouchSurfing
    include CouchSurfingClient::LogHelper

    attr_accessor :username, :password

    def initialize username, password
      self.username = username
      self.password = password
    end

    def cs_connector
      return @cs_connector if @cs_connector

      @cs_connector = CouchSurfingConnector.new username, password
      @cs_connector.logger = logger
      @cs_connector
    end

    def logger= new_logger
      @logger = new_logger
      cs_connector.logger = new_logger
    end

    def cookie_jar
      cs_connector.cookie_jar
    end

    def cookie_jar= cj
      cs_connector.cookie_jar = cj
    end

    def sign_in
      cs_connector.sign_in
      # cs_connector.sign_in username, password
    end

    def signed_in?
      cs_connector.signed_in?
    end

    def sign_out
      cs_connector.sign_out
    end

    def search_by_options options
      logger.debug 'search_by_options'
      response = cs_connector.search options
      SearchPage.new self, response.body
    end

    def search_more_results_by_options options
      logger.debug 'search_more_results_by_options'
      response = cs_connector.get_more_search_results options
      SearchPage.new self, response.body
    end

    def find_location name
      results = cs_connector.location_suggest name

      LocationSuggestParser.new(results.body).to_a.map do |location_hash|
        Location.new self, location_hash
      end
    end

    def get_profile_by_id profile_id
      response = cs_connector.get_profile profile_id
      Profile.new self, response.body
    end

    def get_profile_by_url url
      response = cs_connector.get url
      Profile.new self, response.body
    end

    def search
      SearchQuery.new self
    end

    def get path
      cs_connector.get path
    end
  end

  class Location
    attr_reader :cs

    KEYS = %i(city_id state_id country_id region_id longitude latitude
              population population_dimension has_couchrequest city state
              country region type)

    KEYS.each do |sym|
      define_method sym do
        @location_hash[sym.to_s]
      end
    end

    def keys
      KEYS
    end

    def initialize cs, location_hash
      @cs = cs
      @location_hash = location_hash
    end

    def to_h
      @location_hash
    end

    def search
      @cs.search.location(to_h)
    end

    def to_s
      "#{city}, #{state}, #{country}"
    end
  end

  class Profile < ProfileParser
    attr_reader :cs

    def initialize cs, text
      @cs = cs
      super text
    end
  end
end

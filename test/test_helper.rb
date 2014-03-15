require 'minitest/autorun'
require 'webmock'
require 'vcr'
require 'yaml'
require 'awesome_print'

require 'couchsurfing_client'

TEST_ONLINE = false
TEST_ONLINE = ENV['CS_TEST_ONLINE'].downcase == 'true' if ENV.include? 'CS_TEST_ONLINE'

VERBOSE = false
VERBOSE = ENV['CS_TEST_VERBOSE'].downcase == 'true' if ENV.include? 'CS_TEST_VERBOSE'

USERNAME = ENV['CS_USERNAME'] if ENV['CS_USERNAME']
PASSWORD = ENV['CS_PASSWORD'] if ENV['CS_PASSWORD']

ASSET_PATH = 'test/assets/'

AwesomePrint.defaults = {
  sort_keys: true
}

module Minitest::Assertions
  def mu_pp obj
    obj.ai
  end
end

Minitest::Assertions.diff = 'colordiff -u'

def get_asset name
  File.read File.join(ASSET_PATH + name.to_s)
end

def get_yaml_asset name
  YAML.load get_asset name
end

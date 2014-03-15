require 'test_helper'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock
  c.register_request_matcher :cookie do |request1, request2|
    request1.headers['Cookie'] == request2.headers['Cookie']
  end
end

def vcr options = {}, &block
  options.merge! record: :all if TEST_ONLINE
  VCR.use_cassette name, options.merge({}), &block
end

def new_cs username = USERNAME, password = PASSWORD
  cs = CouchSurfingClient::CouchSurfing.new username, password
  cs.logger = Logger.new STDOUT if VERBOSE
  cs
end

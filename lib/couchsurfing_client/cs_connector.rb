module CouchSurfingClient
  BASE_URL = 'https://www.couchsurfing.org/'
  AUTH_URL = '/n/auth'

  class CouchSurfingConnector
    include CouchSurfingClient::LogHelper

    SEARCH_KEYS = %w(age_high age_low female
                     keyword language_id last_login_days location
                     male map_edges order_by polygon search
                     search_mode several_people submit_button submitted
                     surfer_end_at surfer_end_at_format surfer_end_at_tzo
                     surfer_start_at surfer_start_at_format
                     surfer_start_at_tzo type username which_groups
                     zoom_level)

    SEARCH_MORE_RESULTS_KEYS = %w(page order_by encoded_data
                                  admin_real location search_mode
                                  couchstatus_all search_mode
                                  exclude_user_ids dataonly
                                  csstandard_request type)

    DEFAULT_MORE_SEARCH_RESULTS_PARAMS = {
      'order_by' => nil,
      'encoded_data' => nil,
      'admin_real' => 1,
      'couchstatus_all' => 1,
      'dataonly' => false,
      'csstandard_request' => true,
      'type' => 'html'
    }

    attr_reader :auth_token, :last_response
    attr_accessor :cookie_jar, :verbose

    attr_reader :username, :password

    def initialize username, password
      @username = username
      @password = password
    end

    def sign_in
      load_agent_cookie
      sign_in_agent = SignInPage.new get_root_page

      return true if sign_in_agent.signed_in?
      sign_in_agent.sign_in username, password

      save_agent_cookie

      rescue
      logger.error $ERROR_INFO
      raise
    end

    def signed_in?
      SignInPage.new(get_root_page).signed_in?
    end

    def sign_out
      @cookie_jar = nil
      agent.reset
      agent.shutdown
    end

    def get url
      uri = sanitize_url url
      logger.info "get '#{uri}'"
      with_agent do |agent|
        agent.get uri
      end
    end

    def post url, form_params
      uri = sanitize_url url
      logger.info "post '#{uri}' params: #{form_params.to_yaml}"
      with_agent do |agent|
        result = agent.post uri, form_params
        result
      end
    end

    def location_suggest phrase
      uri = "geosearch/match/#{phrase}/city%3Astate%3Acountry%3Aregion"

      params = {
        'encoded_data' => {},
        'dataonly' => false,
        'csstandard_request' => true,
        'type' => 'json'
      }

      post uri, params
    end

    def get_more_search_results search_options = {}
      search_opts = DEFAULT_MORE_SEARCH_RESULTS_PARAMS.merge search_options
      missing_keys = get_missing_keys SEARCH_MORE_RESULTS_KEYS, search_opts

      unless missing_keys.empty?
        msg = "Following keys are missing in get_more_search_results options: #{missing_keys.to_s}"
        logger.error msg
        fail msg
      end

      post 'search/get_more_results', search_opts
    end

    def search options, type = 'html', dataonly = 'false'
      missing_keys = get_missing_keys SEARCH_KEYS, options

      unless missing_keys.empty?
        msg = "Following keys are missing in search options: #{missing_keys.to_s}"
        logger.error msg
        fail msg
      end

      post 'search/get_results', encoded_data: options.to_json, csstandard_request: 'true', type: type, dataonly: dataonly
    end

    def get_profile profile_id
      get "profile.html?id=#{profile_id}"
    end

    def with_agent &block
      load_agent_cookie
      result = yield agent
      save_agent_cookie

      result
    end

    private

    def sanitize_url url
      uri = URI(URI.escape(url))
      if uri.scheme && uri.host
        uri
      else
        URI(BASE_URL) + uri
      end
    end

    def get_root_page
      get ''
    end

    def save_agent_cookie
      @cookie_jar = agent.cookie_jar.dup
    end

    def load_agent_cookie
      agent.cookie_jar = @cookie_jar.dup if @cookie_jar
    end

    def agent
      return @agent if @agent

      @agent = Mechanize.new
      @agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:30.0) Gecko/20100101 Firefox/30.0'
      @agent.log = logger

      load_agent_cookie
      @agent
    end

    def get_missing_keys keys, hash
      actual_keys = hash.keys
      keys.reduce([]) do |missing, key|
        missing << key unless actual_keys.include?(key)
        missing
      end
    end
  end
end

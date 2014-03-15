module CouchSurfingClient
  class SearchQuery
    attr_accessor :cs

    SEARCH_KEYS = %w( age_high age_low female
                      keyword language_id last_login_days location
                      male map_edges order_by polygon search
                      search_mode several_people submit_button submitted
                      surfer_end_at surfer_end_at_format surfer_end_at_tzo
                      surfer_start_at surfer_start_at_format
                      surfer_start_at_tzo type username which_groups
                      zoom_level )

    ORDER_TYPES = %w( default priority last_login create_date_new create_date_old )

    SEARCH_MODES = %w( S T L H N )

    GENDERS = %w( male female several_people )

    USELESS_SEARCH_PARAMS = {
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
      'map_edges' => ''
    }

    DEFAULT_SEARCH_PARAMS = {
      'age_high' => '',
      'age_low' => '',
      'keyword' => '',
      'language_id' => '',
      'last_login_days' => '',
      'order_by' => 'default',
      'username'  =>  ''
    }

    def initialize cs_instance
      @defined_genders = []
      @options = {}
      @cs = cs_instance
      set_defaults
    end

    def result
      validate

      CouchSurfingClient::SearchResults.new self
    end

    def get number_of_items_to_get=nil
      result.get number_of_items_to_get
    end

    def where opts
      SearchQuery.verify_search_keys opts
      chain @options.merge opts
    end

    def location loc=nil
      if loc
        @location_instance = loc
        where 'location' => loc.to_json
      else
        get_location
      end
    end

    def get_location
      @location_instance ||=
        if options['location']
          Location.new cs, JSON.parse(options['location'])
        else
          nil
        end
    end

    def locals
      where 'search_mode' => 'L'
    end

    def surfers
      where 'search_mode' => 'S'
    end

    def hosts
      where 'search_mode' => 'H'
    end

    def travellers
      where 'search_mode' => 'T'
    end

    def male
      clone.add_gender 'male'
    end

    def female
      clone.add_gender 'female'
    end

    def several_people
      clone.add_gender 'several_people'
    end

    def keyword word
      where 'keyword' => word
    end

    def from_age age
      where 'age_low' => age.to_s
    end

    def to_age age
      where 'age_high' => age.to_s
    end

    def surfer_start_date date
      where 'surfer_start_at' => self.class.format_date(date)
    end

    def surfer_end_date date
      where 'surfer_end_at' => self.class.format_date(date)
    end

    def username name
      where 'search_mode' => 'N', 'username' => name
    end

    def order_by order
      where 'order_by' => order.to_s
    end

    def to_h
      genders_hash.merge @options
    end

    def options
      to_h
    end

    def missing_params
      SEARCH_KEYS.reject { |key| options.keys.include? key }
    end

    def validate
      fail MissingSearchParameterError, "Missing search parameters: #{missing_params}" unless missing_params.empty?

      unexpected_parameters = options.keys.reject { |key| SEARCH_KEYS.include? key }
      fail UnexpectedSearchParameterError, "Unexpected parameters: #{unexpected_parameters}" unless unexpected_parameters.empty?

      order = options['order_by']
      fail InvalidSearchParameterError, "Invalid order_by type '#{order}'" unless ORDER_TYPES.include? order

      validate_search_mode
    end

    protected

    def set_options opts
      @options.merge! opts
    end

    def add_gender gender
      @defined_genders << gender
      self
    end

    private

    def chain opts
      new_clone = clone
      new_clone.set_options(opts)
      new_clone
    end

    def genders_hash
      defined_genders = @defined_genders.empty? ? GENDERS : @defined_genders

      GENDERS.reduce({}) do |hash, gender|
        hash[gender] = defined_genders.include?(gender) ? '1' : '0'
        hash
      end
    end

    def validate_search_mode
      search_mode = options['search_mode']

      unless SEARCH_MODES.include? search_mode
        fail InvalidSearchParameterError, "Invalid search mode '#{search_mode}', valid search modes are #{SEARCH_MODES}"
      end

      if ( search_mode == 'N' ) != ( options['username'] != '' )
        fail InvalidSearchParameterError, "Search mode should be 'N' if and only if username is defined"
      end
    end

    def self.format_date date
      date.strftime '%0m/%d/%Y'
    end

    def self.default_surfer_start_date
      Date.today
    end

    def self.default_surfer_end_date
      default_surfer_start_date >> 2
    end

    def self.verify_search_keys hash
      invalid_keys = hash.keys.reduce([]) do |invalid_keys_array, key|
        invalid_keys_array << key unless SEARCH_KEYS.include? key
        invalid_keys_array
      end

      fail InvalidSearchParameterError, "Invalid search parameters: #{invalid_keys.to_s}" unless invalid_keys.empty?
    end

    def set_defaults
      where USELESS_SEARCH_PARAMS
      where DEFAULT_SEARCH_PARAMS
      surfer_start_date(SearchQuery.default_surfer_start_date)
      surfer_end_date(SearchQuery.default_surfer_end_date)
    end
  end
end

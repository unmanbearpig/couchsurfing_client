module CouchSurfingClient
  module ParserHelper
    protected

    def self.symbolize_hash_keys hash
      hash.reduce({}) { |a, pair| a[ParserHelper.symbolize(pair[0])] = pair[1]; a }
    end

    def self.symbolize string
      string.strip.downcase.gsub(/\s+/, '_').to_sym
    end

    def symbolize string
      ParserHelper.symbolize string
    end

    def parse_yes_no_maybe string
      replacements = {
        'yes' => :yes,
        'no' => :no,
        'maybe' => :maybe,
        'depends' => :maybe
      }

      replace_by_hash string, replacements
    end

    def self.replace_by_hash string, hash
      str = string.strip.downcase
      hash[str] if hash.key? str
    end

    def replace_by_hash value, hash
      ParserHelper.replace_by_hash value, hash
    end

    BOOL_REPLACEMENTS = {
      'yes' => true,
      'true' => true,
      'no' => false,
      'false' => false
    }

    def parse_cs_response cs_response_body
      json = JSON.parse cs_response_body
      json.first['data']
    end

    def parse_american_date date_string
      Date.strptime date_string, '%m/%d/%Y'
    end

    def remove_new_lines_and_tabs string
      return nil unless string
      string.gsub(/[\n\t\r]+/, '')
    end
  end
end

module CouchSurfingClient
  class SearchItem < SearchItemParser
    attr_reader :cs

    def initialize cs, text
      @cs = cs
      super text
    end

    def get_profile
      cs.get_profile_by_id profile_id
    end
  end
end

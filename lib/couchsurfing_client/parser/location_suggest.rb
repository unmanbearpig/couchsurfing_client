module CouchSurfingClient
  class LocationSuggestParser < HtmlParser
    def keys
      [:array]
    end

    lazy_attr :array do
      parse_cs_response(html)['results']
    end

    def to_a
      array
    end
  end
end

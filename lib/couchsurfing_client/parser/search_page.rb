module CouchSurfingClient
  class SearchPageParser < HtmlParser
    include Enumerable

    def keys
      [:item_elements]
    end

    lazy_attr :doc do
      @doc ||= Nokogiri::HTML parse_cs_response(html)
    end

    def each &block
      item_elements.each(&block) if item_elements
    end

    lazy_attr :item_elements do
      doc.css('.profile_result_item')
    end

    lazy_attr :total_results do
      json.first['extra_json_data']['total_found'].gsub(',', '').to_i
    end

    lazy_attr :json do
      JSON.parse html
    end

    def to_a
      item_elements
    end
  end
end

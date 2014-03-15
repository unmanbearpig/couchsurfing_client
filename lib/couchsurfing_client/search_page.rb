module CouchSurfingClient
  class SearchPage < SearchPageParser
    attr_reader :cs

    def initialize cs, text
      @cs = cs
      super text
    end

    lazy_attr :items do
      item_elements.map { |e| SearchItem.new cs, e.to_html }
    end

    lazy_attr :ids do
      items.map { |item| item.profile_id }
    end
  end
end

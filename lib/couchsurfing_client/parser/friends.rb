module CouchSurfingClient
  class FriendsParser < HtmlParser
    def keys
      [:count, :array]
    end

    def to_a
      array
    end

    lazy_attr :array do
      doc.css('td.friends').map { |element| parse_friend element }
    end

    private

    def parse_friend element
      FriendLinkParser.new element.to_html if element
    end
  end
end

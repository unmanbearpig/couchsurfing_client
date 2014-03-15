module CouchSurfingClient
  class FriendLinkParser < HtmlParser
    def keys
      [:name, :thumbnail, :profile_url, :age, :gender, :city, :country,
       :friends_since, :how_met, :friendship_type, :met_in_person,
       :is_verified] # add :hosted, :surfed, :travelled
    end

    lazy_attr :profile_url do
      profile_link.attr('href')
    end

    lazy_attr :name do
      profile_link.text
    end

    lazy_attr :is_verified do
      thumb_link.css('.verified-icon').length > 0
    end

    lazy_attr :thumbnail do
      thumb_link.css('img').first.attr('href')
    end

    lazy_attr :city do
      text_elements[1].text
    end

    lazy_attr :country do
      doc.css('td').children.select { |e| e.name == 'strong' }.first.text
    end

    lazy_attr :age do
      text_elements[0].text.match('(\d+),.*')[1].to_i
    end

    lazy_attr :gender do
      text_elements[0].text.match('\d+, (.*)\s*')[1]
    end

    lazy_attr :friendship_type do
      text_elements[3].text.match('Friendship Type: (.+)\s*')[1]
    end

    lazy_attr :is_verified do
      doc.css('span.verified-icon').length > 0 ? true : false
    end

    lazy_attr :how_met do
      doc.css('td').children.select { |e| e.name == 'em' }.first.text.match('\s*"(.*)"\s*')[1]
    end

    lazy_attr :thumbnail do
      thumb_link.css('img').attr('src').text
    end

    lazy_attr :friends_since do
      text_elements[2].text.match('Friends since (.*)\s*')[1].gsub(/\s+/, ' ')
    end

    lazy_attr :met_in_person do
      doc.css('img[title="Met in person"]').length > 0
    end

    private

    def text_elements
      @text_elements ||= doc.css('td').children
        .select { |e| e.name == 'text' }
        .reject { |e| e.text =~ /\A\s*\Z/ } # skip empty lines
    end

    def thumb_link
      @thumb_link ||= doc.css('a.profile-image').first
    end

    def profile_link
      @profile_link ||= doc.css('a.bold').first
    end
  end
end

module CouchSurfingClient
  class CouchInfoParser
    include ParserHelper

    def self.parse element
      return @couch_info if defined? @couch_info

      elements = get_elements(element)

      result = get_couch_info_hash elements

      result
    end

    private

    def self.get_couch_info_hash elements
      result = {}

      key = nil
      value = nil

      elements.each do |e|
        if e.name == 'strong'
          # set value to true if there is a key but no value
          result[key] = true if key

          key = e.text.match(/\A(.*?)[\:\s]*\Z/)[1]
        elsif e.name == 'text'
          value = e.text.strip
          result[key] = value if key && value
          key = value = nil
        end
      end

      ParserHelper.symbolize_hash_keys result
    end

    def self.get_elements parent
      couch_elements = []

      going_through_couch_elements = false

      parent.children.each do |element|
        if going_through_couch_elements
          couch_elements.push element
        else
          if element.attr('id') == 'couchinfo'
            going_through_couch_elements = true
          end
        end
      end

      couch_elements
    end
  end

  class GeneralInfoParser < HtmlParser
    def item name
      hash[name] if hash.key? name
    end

    def text_item name
      item(name).text
    end

    def elements
      doc
    end

    def elements_hash
      pairs = elements.reduce([]) do |a, element|
        name_element = element.css('th').first
        value_element = element.css('td').first

        if name_element && value_element
          hash_key = name_element.text.empty? ? nil : symbolize(name_element.text)

          a << [ hash_key , value_element ]
        end

        a
      end

      Hash[pairs]
    end

    lazy_attr :hash do
      elements_hash
    end

    def to_h
      hash
    end

    # lazy_attr :hash do
    #   hash = {}

    #   elements.each do |item|
    #     name_element = item.css('th').first
    #     value_element = item.css('td').first

    #     next unless name_element && value_element

    #     key = name_element.text.strip
    #     value = value_element.text.strip
    #     hash[key] = value if key
    #   end

    #   @generalinfo = hash
    # end
  end

  class ProfileParser < HtmlParser
    KEYS = %i(name mission couch_available is_verified requests_replied_to last_in_time
              last_in_location member_since profile_views age birthday gender member_name
              occupation hometown profile_pic languages groups preferred_gender smoking
              has_children has_pets can_host_pets can_host_children max_surfers_per_night shared_sleeping_surface
              shared_room couch_description couch_pic friends personal_description how_i_participate
              cs_experience interests music_movies_books people_i_enjoy wisdom amazing_thing
              opinion_on_cs locations_travelled total_references positive_references
              neutral_references negative_references references_from_hosts references_from_surfers
              travelling_references references profile_url profile_id)

    NOT_IMPLEMENTED_KEYS = %i(friends references references_from_hosts references_from_surfers
                              travelling_references locations_travelled groups
                              positive_references neutral_references negative_references)


    def keys
      KEYS.reject { |k| NOT_IMPLEMENTED_KEYS.include? k }
    end

    lazy_attr :name do
      doc.css('.profile_header h1.profile').text.strip
    end

    lazy_attr :profile_url do
      doc.css('table td a')
        .select { |element| element.text == 'Direct Profile URL' }
        .first.attr('href')
    end

    lazy_attr :profile_id do
      send_message_link.match(/\/send_message\.html\?id\=(\S+)/)[1]
    end

    lazy_attr :mission do
      doc.css('table.profile_header tr td div em').text.strip
    end

    lazy_attr :is_verified do
      !doc.css('div.verification_information img.mr5').empty?
    end

    lazy_attr :requests_replied_to do
      general_info.text_item :couchsurf_requests_replied_to
    end

    lazy_attr :last_in_time do
      doc.css('span#last_login').children.first.text
    end

    lazy_attr :last_in_location do
      doc.css('span#last_login').children[2].text
    end

    lazy_attr :member_since do
      general_info.text_item :member_since
    end

    lazy_attr :profile_views do
      general_info.text_item :profile_views
    end

    lazy_attr :age do
      general_info.text_item(:age).to_i
    end

    lazy_attr :birthday do
      general_info.item(:birthday).children.first.text
    end

    lazy_attr :gender do
      Gender.new general_info.text_item :gender
    end

    lazy_attr :member_name do
      general_info.text_item :membername
    end

    lazy_attr :occupation do
      general_info.text_item :occupation
    end

    lazy_attr :education do
      general_info.text_item :education
    end

    lazy_attr :hometown do
      general_info.text_item :grew_up_in
    end

    lazy_attr :profile_pic do
      doc.css('td.right_profile').children[2].css('img').attr('src').value
    end

    lazy_attr :languages do
      result = {}

      doc.css('ul.languages').children.each do |lang_item|
        if lang_item.children.length > 0
          lang_name = lang_item.children.first.text
          lang_skill = lang_item.css('sup').text
          result[lang_name] = lang_skill
        end
      end

      result
    end

    # lazy_attr :groups do
    #   result = {}

    #   doc.css('div#show_groups table td').each do |group_element|
    #     group = {}

    #     next unless group_element.css('em').length > 0 and group_element.css('img').length > 0

    #     group_link = group_element.css('a').first
    #     if group_link.children.length > 1
    #       group[:name] = group_link.children[1].text
    #       group[:thumbnail] = group_element.css('img').first.attr('src')
    #     else
    #       group[:name] = group_link.children.first.text
    #       group[:thumbnail] = nil
    #     end

    #     group[:url] = group_element.css('a').first.attr('href')
    #     group[:why] = group_element.css('em').first.text

    #     result.merge!(group)
    #   end
    # end

    lazy_attr :preferred_gender do
      Gender.new couch_info[:preferred_gender]
    end

    lazy_attr :couch_available do
      parse_yes_no_maybe couch_info[:couch_available]
    end

    lazy_attr :has_children do
      parse_yes_no_maybe couch_info[:has_children]
    end

    lazy_attr :can_host_children do
      parse_yes_no_maybe couch_info[:can_host_children]
    end

    lazy_attr :has_pets do
      parse_yes_no_maybe couch_info[:has_pets]
    end

    lazy_attr :can_host_pets do
      parse_yes_no_maybe couch_info[:can_host_pets]
    end

    lazy_attr :max_surfers_per_night do
      couch_info[:max_surfers_per_night].to_i
    end

    lazy_attr :shared_sleeping_surface do
      parse_yes_no_maybe couch_info[:shared_sleeping_surface]
    end

    lazy_attr :shared_room do
      parse_yes_no_maybe couch_info[:shared_room]
    end

    lazy_attr :smoking do
      [:no_smoking_allowed, :smoking_allowed, :member_smokes]
        .reduce(nil) { |a, key| couch_info.key?(key) ? key : a }
    end

    lazy_attr :couch_description do
      couch_info_element.css('p').text
    end

    lazy_attr :couch_pic do
      couch_info_element.css('img').attr('src').text
    end

    lazy_attr :personal_description do
      profile_info_text 'Personal Description'
    end

    lazy_attr :how_i_participate do
      profile_info_text 'How I Participate in CS'
    end

    lazy_attr :interests do
      profile_info_text 'Interests'
    end

    lazy_attr :cs_experience do
      profile_info_text 'Couchsurfing Experience'
    end

    lazy_attr :music_movies_books do
      profile_info_text 'Music, Movies, Books'
    end

    lazy_attr :people_i_enjoy do
      profile_info_text 'Types of People I enjoy'
    end

    lazy_attr :wisdom do
      profile_info_text 'Teach, Learn, Share'
    end

    lazy_attr :amazing_thing do
      profile_info_text "One Amazing Thing I've Seen or Done"
    end

    lazy_attr :opinion_on_cs do
      profile_info_text 'Opinion on the Couchsurfing.org Project'
    end


    # lazy_attr :friends do
    #   a = friends_elements
    #   friends_elements.map do |element|
    #     # TODO: write test for it and fix it
    #     new_friend element
    #   end
    # end

    lazy_attr :total_references do
      doc.css('div#total_ref span').text.match(/\d+/)[0].to_i
    end

    lazy_attr :positive_references do
    end

    lazy_attr :neutral_references do
    end

    lazy_attr :negative_references do
    end

    def to_h
      hash = super

      %i(gender preferred_gender)
        .each { |key| hash[key] = hash[key].to_sym if hash[key].respond_to? key }

      hash
    end

    private

    def profile_info_text title
      elements = profile_info_elements[title]
      elements_to_html elements if elements
    end

    def send_message_link
      @send_message_link ||= doc
        .css('div#top_profile_cr_and_navigation_pill div.m5 a')
        .select { |element| element.text == 'Send Message' }.first
        .attr('href')
    end

    def friends_elements
      doc.css('table.friends td')
    end

    def profile_info_parent
      doc.css('td.right_profile').first
    end

    def elements_to_html elements
      elements.reduce('') { |str, element| str + element.to_html }
        .gsub("\r", '')
    end

    def general_info_element
      doc.css('table.generalinfo tr')
    end

    def general_info
      return @general_info if defined? @general_info

      @general_info = GeneralInfoParser.new general_info_element
    end

    def profile_info_elements
      return @profile_info_elements if defined? @profile_info_elements

      result = {}

      key = nil

      profile_info_parent.children.each do |element|
        if element.name == 'h2' && element.attr('class') == 'profile'
          key = element.text
          result[key] = []
        else
          if element.name == 'script' || element.attr('class') == 'profile_locations_map'
            break
          end

          result[key] << element if key
        end
      end

      @profile_info_elements = result
    end

    def couch_info
      @couch_info ||= CouchInfoParser.parse couch_info_element
    end

    def couch_info_element
      doc.css('#couchinfo').first.parent
    end

    protected

    def new_friend element
      FriendLinkParser.new element
    end
  end
end

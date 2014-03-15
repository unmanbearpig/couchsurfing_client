module CouchSurfingClient
  class SearchItemParser < HtmlParser
    KEYS = [ :profile_pic, :href, :profile_id, :name, :lives_in, :last_in_location, :last_in_time,
             :friends_count, :references_count, :photos_count, :mission, :age, :gender,
             :about, :languages, :occupation ]

    COUCH_REQUEST_KEYS = [ :open_request, :couch_request_city, :arrival_date, :departure_date,
                           :number_of_surfers, :city_couchrequest_id ]

    def keys
      is_couch_request ? KEYS + COUCH_REQUEST_KEYS : KEYS
    end

    def couch_request_keys
      COUCH_REQUEST_KEYS
    end

    lazy_attr :profile_pic do
      doc.css('.profile_result_link_img').attribute('src').value
    end

    lazy_attr :href do
      doc.css('span.result_username a').attribute('href').value
    end

    lazy_attr :profile_id do
      href.match(/[\?\&]id\=(\w+)[\&$]/)[1]
    end

    lazy_attr :name do
      profile_link_node.text
    end

    lazy_attr :lives_in do
      doc.css('.gray_sm :nth-child(2)').text
    end

    lazy_attr :last_in_location do
      last_time_and_location.split(' - ')[0]
    end

    lazy_attr :last_in_time do
      last_time_and_location.split(' - ')[1]
    end

    lazy_attr :friends_count do
      doc.css('ul.profile_count :nth-child(1) .count').text.to_i
    end

    lazy_attr :references_count do
      doc.css('ul.profile_count :nth-child(2) .count').text.to_i
    end

    lazy_attr :photos_count do
      doc.css('ul.profile_count :nth-child(3) .count').text.to_i
    end

    lazy_attr :mission do
      user_details_elements['Mission'].text.strip if user_details_elements['Mission']
    end

    lazy_attr :age do
      basics_elements[2].to_i
    end

    lazy_attr :gender do
      Gender.new basics_elements[1]
    end

    lazy_attr :occupation do
      basics_elements[3]
    end

    lazy_attr :about do
      about_element = user_details_elements['About']

      if about_element
        result = about_element.children[0].text.lstrip

        more_text_element = about_element.css('span.show_more_text').first
        result += more_text_element.text.strip if more_text_element

        remove_new_lines_and_tabs result
      else
        nil
      end
    end

    lazy_attr :languages do
      parse_user_languages user_details_elements['Languages']
    end


    # Couch Request stuff

    lazy_attr :is_couch_request do
      search_item = self
      couch_request_keys
        .map { |key| search_item.send(key) != nil }
        .include?(true)
    end

    def couch_request?
      is_couch_request
    end

    lazy_attr :city_couchrequest_id do
      doc.css('span.report_this').attr('id').text.match(/report_(\d+)\Z/)[1]
    end

    lazy_attr :number_of_surfers do
      return nil unless couch_request_details['Number of Surfers:']
      couch_request_details['Number of Surfers:'].to_i
    end

    lazy_attr :departure_date do
      parse_american_date(couch_request_details['Departure Date:']).to_s
    end

    lazy_attr :arrival_date do
      parse_american_date(couch_request_details['Arrival Date:']).to_s
    end

    lazy_attr :couch_request_city do
      remove_new_lines_and_tabs couch_request_details['City:']
    end

    lazy_attr :open_request do
      doc.css('.media div.bd p').first.text
    end

    def to_h
      hash = super
      hash[:gender] = hash[:gender].capitalize
      hash
    end

    def to_s
      "'#{name}' (#{profile_id}), #{age}#{gender.short} from '#{lives_in}'"
    end

    private

    def couch_request_details
      @couch_request_details ||= doc
        .css('div.open_request.media div.details .line')
        .reduce({}) do |hash, element|

        key = element.css('dt').text
        value = element.css('dd').text
        hash[key] = value
        hash
      end
    end

    def profile_link_node
      @profile_link_node ||= doc.css('span.result_username a')
    end

    def last_time_and_location
      @last_time_and_location ||= doc.css('.gray_sm :nth-child(5)').text
    end

    def user_details_elements
      return @user_details_elements if @user_details_elements

      result = {}

      doc.css('.profile_details').css('.line').map do |details_item|
        item_name = details_item.css('.bold').text
        item_value = details_item.css(':nth-child(2)')

        result[item_name] = item_value
      end

      result
    end

    def basics_elements
      @basic_elements ||= user_details_elements['Basics'].text.match(/\A(.*?)\, (.*?)(?:\, (.*))?\Z/)
    end

    def parse_user_languages languages_node
      lang_array = languages_node.children.map { |n| n.text.gsub(',', '').strip }
      lang_array = lang_array[0..-2] if lang_array.length.odd?
      Hash[*lang_array].reject { |lang, exp| lang == '...' }
    end
  end
end

module CouchSurfingClient
  class HtmlParser < ParserBase
    include ParserHelper

    attr_reader :html

    def initialize input_html
      super()
      @html = input_html
      @doc = @html if @html.kind_of?(Nokogiri::XML::Document) || @html.kind_of?(Nokogiri::XML::NodeSet)
    end

    lazy_attr :doc do
      Nokogiri::HTML(html)
    end

    def server_error?
      doc ? doc.css('div#framework_error').length > 0 : nil
    end

    def success?
      super && !server_error?
    end
  end
end

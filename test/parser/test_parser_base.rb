require 'test_helper'

module CouchSurfingClient
  class TestParserBase < Minitest::Test

    class ErrorParser < ParserBase
      def keys
        [:err]
      end

      lazy_attr :err do
        fail 'Test error'
      end
    end

    class SimpleParser < ParserBase
      attr_accessor :string

      def keys
        [:string]
      end

      def initialize string
        super()
        self.string = string
      end

      lazy_attr :string do
        string
      end
    end

    class SimpleHtmlParser < HtmlParser
      def keys
        [:text]
      end

      lazy_attr :text do
        doc.text
      end
    end

    def test_parser_saves_errors
      parser = ErrorParser.new
      parser.err

      assert_equal [:err], parser.errors.keys
      assert_equal 'Test error', parser.errors[:err].message
      refute parser.success?
    end

    def test_parser_check_all_fields_for_errors
      parser = ErrorParser.new

      refute parser.success?
      assert_equal 'Test error', parser.errors[:err].message
    end

    def test_parser_fields
      test_string = 'test'
      parser = SimpleParser.new test_string

      assert_equal test_string, parser.string
      assert parser.success?
    end

    def test_html_parser
      parser = SimpleHtmlParser.new '<div>test string</div>'
      assert_equal 'test string', parser.text
    end

  end
end

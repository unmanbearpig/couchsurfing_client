module CouchSurfingClient
  class Error < StandardError
    attr_accessor :original

    def initialize msg = nil, original_error = $ERROR_INFO
      @original = original_error
      super msg
    end

    def to_s
      if original
        "#{super}: \n#{original.to_s}"
      else
        super
      end
    end
  end

  class SignInError < Error; end

  class SearchParameterError < Error; end

  class InvalidSearchParameterError < Error; end

  class UnexpectedSearchParameterError < Error; end

  class MissingSearchParameterError < Error; end

end

module CouchSurfingClient
  class NullLogger
    def method_missing method, *args
      # ignore everything
    end
  end

  module LogHelper
    attr_writer :logger

    def logger
      @logger || NullLogger.new
    end
  end
end

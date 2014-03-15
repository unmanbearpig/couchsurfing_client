module CouchSurfingClient
  class ParserBase
    def initialize
      @errors = {}
    end

    def to_h
      fields_hash
    end

    def errors
      @errors
    end

    def success?
      parse_all_fields
      errors.length == 0
    end

    private

    def parse_all_fields
      keys.each { |key| send(key) }
    end

    def fields_hash
      keys.reduce({}) { |a, key| a[key] = send(key); a }
    end

    def log_error key, error
      errors[key] = error
    end

    def self.lazy_attr name, &block
      define_method name do
        ivar_name = "@#{name.to_s}"
        return instance_variable_get(ivar_name) if instance_variable_defined?(ivar_name)

        result = instance_eval { with_error_log name, &block }

        instance_variable_set ivar_name, result

        result
      end
    end

    protected

    def with_error_log key, &block
      instance_eval(&block)
    rescue StandardError => e
      log_error(key, e)
      nil
    end

    private_class_method :lazy_attr
  end
end

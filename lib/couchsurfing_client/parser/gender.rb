module CouchSurfingClient
  class Gender
    attr_reader :orig_string

    GENDERS = [:male, :female, :several_people, :any]

    GENDER_SHORT = {
      male: 'M',
      female: 'F',
      several_people: 'S',
      any: '*',
      invalid: '?'
    }

    GENDER_STRING = {
      male: 'Male',
      female: 'Female',
      several_people: 'Several people',
      any: 'Any',
      invalid: 'Invalid gender'
    }

    def initialize gender_string_or_sym
      if gender_string_or_sym.respond_to? :to_sym
        @sym = gender_string_or_sym.to_sym if GENDERS.include? gender_string_or_sym.to_sym
      end

      @orig_string = gender_string_or_sym
    end

    def to_sym
      sym
    end

    def short
      GENDER_SHORT[sym]
    end

    def to_s
      GENDER_STRING[sym]
    end

    def capitalize
      to_s.capitalize
    end

    def male?
      sym == :male
    end

    def female?
      sym == :female
    end

    def several_people?
      sym == :several_people
    end

    def any?
      sym == :any
    end

    def == other
      return false unless other.respond_to? :to_sym
      sym == other.to_sym
    end

    def === other
      sym == Gender.new(other).to_sym
    end

    def valid?
      sym == :invalid
    end

    def hash
      sym.hash
    end

    def self.male
      Gender.new :male
    end

    def self.female
      Gender.new :female
    end

    def self.several_people
      Gender.new :several_people
    end

    def self.any
      Gender.new :any
    end

    def self.parse string
      Gender.new string
    end

    private

    def sym
      @sym ||= case @orig_string.strip.downcase
               when 'male' then :male
               when 'female' then :female
               when 'several people' then :several_people
               when 'several_people' then :several_people
               when 'any' then :any
               else :invalid
               end
    end
  end
end

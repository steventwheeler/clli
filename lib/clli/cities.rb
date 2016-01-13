class CLLI
  ##
  # This module provides methods to lookup the entity code description for a
  # parsed +CLLI+ string.
  module Cities
    ##
    # When this modeule is included then extend the including class with the
    # methods defined in +ClassMethods+.
    def self.included(o)
      o.extend(ClassMethods)
    end

    ##
    # These methods will be available in the CLLI class.
    module ClassMethods
      include Pattern

      @cities_data = nil

      ##
      # Lookup the name of the city that the first 6 characters of the +CLLI+
      # corresond to.
      #
      # Params:
      # +place+::   the first four characters of the +CLLI+.
      # +region+::  the next two characters of the +CLLI+.
      def city_name(place, region)
        @cities_data ||= YAMLData.new(%w(clli data cities.yml))
        @cities_data.get(region, place, 'city')
      end
    end
  end
end

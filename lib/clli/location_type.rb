class CLLI
  ##
  # This module provides methods to lookup the location code description for a
  # parsed +CLLI+ string.
  module LocationType
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

      @location_type_data = nil

      ##
      # Lookup the entity code description for a parsed +CLLI+ string.
      #
      # Params:
      # +code+:: the +CLLI+ +:location_code+ or +:customer_code+ attribute value.
      def location_type(code)
        @location_type_data ||= YAMLData.new(%w(clli data location_types.yml))
        @location_type_data.get(code)
      end
    end
  end
end

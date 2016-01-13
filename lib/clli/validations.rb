class CLLI
  ##
  # This module provides methods to validate the parsed +CLLI+ attributes.
  module Validations
    ##
    # When this modeule is included then extend the including class with the
    # methods defined in +ClassMethods+.
    def self.included(o)
      o.extend(ClassMethods)
    end

    ##
    # These methods will be available in the CLLI class.
    module ClassMethods
      def validate(str, attributes, **options)
        validate_place(str, attributes[:place], options)
        validate_region(str, attributes[:region], options)
        %i(network_site entity_code location_code location_id customer_code customer_id).each do |attribute|
          send("validate_#{attribute}", str, attributes[attribute], options) if attributes.key?(attribute)
        end
      end

      private

      def validate_place(str, place, **options)
        error_prefix = "Invalid CLLI #{str.inspect} place (characters 0..3)"
        validate_attribute(error_prefix, place, 4, /\A[A-Z]+\s*\z/, options)
      end

      def validate_region(str, region, **options)
        error_prefix = "Invalid CLLI #{str.inspect} region (characters 4..5)"
        validate_attribute(error_prefix, region, 2, /\A[A-Z]{2}\z/, options)
      end

      def validate_network_site(str, site, **options)
        error_prefix = "Invalid CLLI #{str.inspect} network site (characters 6..7)"
        validate_attribute(error_prefix, site, 2, /\A([A-Z]{2}|[0-9]{2})\z/, options)
      end

      def validate_entity_code(str, entity_code, **options)
        error_prefix = "Invalid CLLI #{str.inspect} entity code (characters 8..11)"
        validate_attribute(error_prefix, entity_code, 3, /\A[A-Z0-9]{3}\z/, options)
      end

      def validate_location_code(str, location, **options)
        error_prefix = "Invalid CLLI #{str.inspect} non-building location code (character 8)"
        validate_attribute(error_prefix, location, 1, /\A[A-Z]\z/, options)
      end

      def validate_location_id(str, location, **options)
        error_prefix = "Invalid CLLI #{str.inspect} non-building location ID (characters 9..11)"
        validate_attribute(error_prefix, location, 4, /\A[0-9]{4}\z/, options)
      end

      def validate_customer_code(str, location, **options)
        error_prefix = "Invalid CLLI #{str.inspect} customer location code (characters 8)"
        validate_attribute(error_prefix, location, 1, /\A[0-9]\z/, options)
      end

      def validate_customer_id(str, location, **options)
        error_prefix = "Invalid CLLI #{str.inspect} customer location ID (characters 9..11)"
        validate_attribute(error_prefix, location, 4, /\A[A-Z][0-9]{3}\z/, options)
      end

      def validate_attribute(error_prefix, value, length, regexp, **options)
        fail "#{error_prefix} cannot be nil." if value.nil?
        fail "#{error_prefix} cannot be empty." if value.to_s.empty?
        fail "#{error_prefix} must be #{length} #{pluralize(length, 'character')} long." unless value.to_s.size == length
        return unless options[:strict]
        fail "#{error_prefix} is not properly formatted." unless regexp =~ value
      end

      def pluralize(count, singular, plural = nil)
        plural ||= singular + 's'
        count == 1 ? singular : plural
      end
    end
  end
end

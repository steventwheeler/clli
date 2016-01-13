class CLLI
  # This module is used to convert CLLI region codes into ISO 3166 codes.
  module ISO3166
    ##
    # When this modeule is included then extend the including class with the
    # methods defined in +ClassMethods+.
    def self.included(o)
      o.extend(ClassMethods)
    end

    ##
    # These methods will be available in the CLLI class.
    module ClassMethods
      @region_conversion_data = nil

      ##
      # Convert the +CLLI+ region code into an ISO 3166 country code.
      #
      # Params:
      # +region-code+:: the +CLLI+ +:region+ attribute value.
      def iso_country(region_code)
        load_data
        return @region_conversion_data[region_code]['country'] if @region_conversion_data.key?(region_code)
        country = ::ISO3166::Country.new(region_code)
        country.nil? ? 'ZZ' : country.alpha2
      end

      ##
      # Lookup the name of the country for the specified +region_code+.
      #
      # Params:
      # +region-code+:: the +CLLI+ +:region+ attribute value.
      def country_name(region_code)
        country_code = iso_country(region_code)
        country = ::ISO3166::Country.new(country_code)
        return if country.nil?
        country.name
      end

      ##
      # Convert the +CLLI+ region code into an ISO 3166 state code.
      #
      # Params:
      # +region-code+:: the +CLLI+ +:region+ attribute value.
      def iso_state(region_code)
        load_data
        return @region_conversion_data[region_code]['state'] if @region_conversion_data.key?(region_code)
      end

      ##
      # Lookup the name of the state for the specified +region_code+.
      #
      # Params:
      # +region-code+:: the +CLLI+ +:region+ attribute value.
      def state_name(region_code)
        state_code = iso_state(region_code)
        return unless state_code
        country_code = iso_country(region_code)
        return unless country_code
        country = ::ISO3166::Country.new(country_code)
        return unless country
        state_data = country.states[state_code]
        return unless state_data
        state_data['name']
      end

      private

      ##
      # Get an array of all the state codes in the specified country.
      #
      # Params:
      # +iso_country+:: the ISO 3166 country code.
      def state_codes(iso_country)
        country = ::ISO3166::Country.new(iso_country)
        return [] unless country
        country.states.keys
      end

      ##
      # Load the region code conversion data.
      def load_data
        return unless @region_conversion_data.nil?
        data = {}
        # Load the YAML region code conversion data.
        data.merge!(YAMLData.new(%w(clli data region_conversions.yml)).data)

        # load the US & Canadian state conversions.
        data.merge!(us_ca_state_conversions)
        @region_conversion_data = data
      end

      ##
      # load the US & Canadian state conversions.
      def us_ca_state_conversions
        %w(US CA).each_with_object({}) do |country, data|
          state_codes(country).each do |state|
            data[state] = { 'state' => state, 'country' => country }
          end
        end
      end
    end
  end
end

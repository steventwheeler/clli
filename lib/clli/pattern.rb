class CLLI
  ##
  # This module provides the various patterns used for parsing +CLLI+ strings.
  module Pattern
    ##
    # When this modeule is included then extend the including class with the
    # methods defined in +ClassMethods+.
    def self.included(o)
      o.extend(ClassMethods)
    end

    ##
    # These methods will be available in the CLLI class.
    module ClassMethods
      DEFAULT_PATTERN_OPTIONS = {
        strict: true,
        place_group: 'place',
        region_group: 'region',
        network_site_group: 'network_site',
        entity_code_group: 'entity_code',
        nonbuilding_code_group: 'location_code',
        nonbuilding_id_group: 'location_id',
        customer_code_group: 'customer_code',
        customer_id_group: 'customer_id'
      }

      ##
      # Get the complete +CLLI+ pattern.
      #
      # Params:
      # +options+:: the following options are supported.
      # [:strict]                 whether or not the rules in section
      #                           +795-100-100+ are enforced for all fields.
      # [:place_group]            the name to use for the place abbreviation.
      # [:region_group]           the name to use for the region code.
      # [:network_site_group]     the name to use for the network site code.
      # [:entity_code_group]      the name to use for the entity code.
      # [:nonbuilding_code_group] the name to use for the nonbuilding code.
      # [:nonbuilding_id_group]   the name to use for the nonbuilding ID.
      # [:customer_code_group]    the name to use for the customer code.
      # [:customer_id_group]      the name to use for the customer ID.
      def pattern(**options)
        place = place_pattern(options)
        network_site = network_site_pattern(options)
        entity_code = entity_code_pattern(options)
        nonbuilding_location = nonbuilding_location_pattern(options)
        customer_location = customer_location_pattern(options)
        "\\A#{place}(?:#{network_site}(?:#{entity_code})?|#{nonbuilding_location}|#{customer_location})\\z"
      end

      ##
      # Get the complete +CLLI+ pattern as a compiled +Regexp+.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def regexp(**options)
        Regexp.new(pattern(options))
      end

      ##
      # Get the place abbreviation and region code pattern.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def place_pattern(**options)
        options = DEFAULT_PATTERN_OPTIONS.merge(options)
        pattern = named_group(options[:place_group], options[:strict] ? "[#{a}]{4}|[#{a}]{3}[ ]|[#{a}]{2}[ ]{2}" : "[#{x}\s]{4}")
        pattern << named_group(options[:region_group], '[A-Z]{2}')
      end

      ##
      # Get the network site code pattern.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def network_site_pattern(**options)
        options = DEFAULT_PATTERN_OPTIONS.merge(options)
        named_group(options[:network_site_group], options[:strict] ? "(?:[#{a}]{2}|[#{n}]{2})" : "(?:[#{a}#{n}]{2})")
      end

      ##
      # Get the entity code pattern.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def entity_code_pattern(**options)
        options = DEFAULT_PATTERN_OPTIONS.merge(options)
        named_group(options[:entity_code_group], options[:strict] ? strict_entity_code_pattern : relaxed_entity_code_pattern)
      end

      def strict_entity_code_pattern
        [
          switching_entity_code_pattern, # (Table B)
          switchboard_and_desk_entity_code_pattern, # (Table C)
          miscellaneous_switching_termination_entity_code_pattern, # (Table D)
          nonswitching_entity_code_pattern # (Table E)
        ].join('|')
      end

      def relaxed_entity_code_pattern
        '[A-Z0-9]{3}'
      end

      # Switching Entities (Table B)
      def switching_entity_code_pattern
        [
          "(?:MG|SG|CG|DS|RL|PS|RP|CM|VS|OS|OL|[#{n}][#{n}])[#{x1}]",
          "[CB#{n}][#{n}]T",
          "[#{n}]GT",
          "Z[#{a}]Z",
          "RS[#{n}]",
          "X[#{a}]X",
          "CT[#{x1}]"
        ].join('|')
      end

      # Switchboard and Desk Termination Entities (Table C)
      def switchboard_and_desk_entity_code_pattern
        "[#{n}][CDBINQWMVROLPEUTZ#{n}]B"
      end

      # Miscellaneous switching termination entities (Table D)
      def miscellaneous_switching_termination_entity_code_pattern
        ["[#{n}][AXCTWDEINPQ]D", "[#{x}][UM]D"].join('|')
      end

      # Non-Switching Entities (Table E)
      def nonswitching_entity_code_pattern
        ["[FAEKMPSTW][#{x2}][#{x1}]", "Q[#{n}][#{n}]"].join('|')
      end

      ##
      # Get the non-building location code pattern.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def nonbuilding_location_pattern(**options)
        options = DEFAULT_PATTERN_OPTIONS.merge(options)
        pattern = named_group(options[:nonbuilding_code_group], "[#{a}]")
        pattern << named_group(options[:nonbuilding_id_group], "[#{n}]{4}")
      end

      ##
      # Get the customer non-building location pattern.
      #
      # Params:
      # +options+:: see #pattern for more details.
      def customer_location_pattern(**options)
        options = DEFAULT_PATTERN_OPTIONS.merge(options)
        pattern = named_group(options[:customer_code_group], "[#{n}]")
        pattern << named_group(options[:customer_id_group], "[#{a}][#{n}]{3}")
      end

      ##
      # A character group excluding B, D, I, O, T, U, W, and Y.
      def a1
        'ACE-HJ-NP-SVXZ'
      end

      ##
      # A character group excluding G.
      def a2
        'A-FH-Z'
      end

      ##
      # A character group containing all alpha characters.
      def a
        'A-Z'
      end

      ##
      # A character group containing all digit characters.
      def n
        '0-9'
      end

      ##
      # A character group containing all alpha and digit characters.
      def x
        a + n
      end

      ##
      # A character group containing both +a1+ and all digit characters.
      def x1
        a1 + n
      end

      ##
      # A character group containing both +a2+ and all digit characters.
      def x2
        a2 + n
      end

      private

      ##
      # Generate a named group using the specified +name+ and +pattern+. If the
      # +name+ is +nil+ then just the +pattern+ will be returned.
      #
      # Params:
      # +name+::    the name of the group.
      # +pattern+:: the pattern inside the group.
      def named_group(name, pattern)
        return pattern if name.nil? || name.respond_to?(:empty?) && name.empty?
        "(?<#{name}>#{pattern})"
      end
    end
  end
end

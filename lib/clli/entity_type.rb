class CLLI
  ##
  # This module provides methods to lookup the entity code description for a
  # parsed +CLLI+ string.
  module EntityType
    ##
    # When this modeule is included then extend the including class with the
    # methods defined in +ClassMethods+.
    def self.included(o)
      o.extend(ClassMethods)
    end

    ##
    # These methods will be available in the +CLLI+ class.
    module ClassMethods
      include Pattern

      @entity_type_data = nil

      ##
      # Lookup the entity code description for a parsed +CLLI+ string.
      #
      # Params:
      # +code+:: the +CLLI+ +:entity_code+ attribute value.
      def entity_type(code)
        @entity_type_data ||= YAMLData.new(%w(clli data entity_types.yml))
        @entity_type_data.get(*code_keys(code))
      end

      private

      SWITCHING_TYPE_PATTERNS = {
        "MG[#{x1}]" => %w(switching_types MGx),
        "SG[#{x1}]" => %w(switching_types SGx),
        "CG[#{x1}]" => %w(switching_types CGx),
        "DS[#{x1}]" => %w(switching_types DSx),
        "[#{n}]{2}[#{x1}]" => %w(switching_types nnx),
        "[#{n}]{2}T" => %w(switching_types nnT),
        "C[#{n}]T" => %w(switching_types CnT),
        "B[#{n}]T" => %w(switching_types BnT),
        "[#{n}]GT" => %w(switching_types nGT),
        "Z[#{a}]Z" => %w(switching_types ZaZ),
        "RS[#{n}]" => %w(switching_types RSn),
        "X[#{a}]X" => %w(switching_types XaX),
        "CT[#{x1}]" => %w(switching_types CTx)
      }

      ##
      # Determine which key to use for the parsed entity code.
      #
      # Params:
      # +code+:: the +CLLI+ +:entity_code+ attribute value.
      def code_keys(code)
        SWITCHING_TYPE_PATTERNS.each do |pattern, keys|
          return keys if Regexp.new(pattern) =~ code
        end
        case code
        when Regexp.new(switchboard_and_desk_entity_code_pattern) then ['switchboard_and_desk', code[1]]
        when Regexp.new(miscellaneous_switching_termination_entity_code_pattern) then ['miscellaneous_switching_termination', code[1]]
        when Regexp.new(nonswitching_entity_code_pattern) then ['nonswitching_types', code[0]]
        end
      end
    end
  end
end

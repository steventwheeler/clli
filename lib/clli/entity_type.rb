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

      ##
      # Determine which key to use for the parsed entity code.
      #
      # Params:
      # +code+:: the +CLLI+ +:entity_code+ attribute value.
      def code_keys(code)
        case code
        when Regexp.new("MG[#{x1}]") then %w(switching_types MGx)
        when Regexp.new("SG[#{x1}]") then %w(switching_types SGx)
        when Regexp.new("CG[#{x1}]") then %w(switching_types CGx)
        when Regexp.new("DS[#{x1}]") then %w(switching_types DSx)
        when Regexp.new("[#{n}]{2}[#{x1}]") then %w(switching_types nnx)
        when Regexp.new("[#{n}]{2}T") then %w(switching_types nnT)
        when Regexp.new("C[#{n}]T") then %w(switching_types CnT)
        when Regexp.new("B[#{n}]T") then %w(switching_types BnT)
        when Regexp.new("[#{n}]GT") then %w(switching_types nGT)
        when Regexp.new("Z[#{a}]Z") then %w(switching_types ZaZ)
        when Regexp.new("RS[#{n}]") then %w(switching_types RSn)
        when Regexp.new("X[#{a}]X") then %w(switching_types XaX)
        when Regexp.new("CT[#{x1}]") then %w(switching_types CTx)
        when Regexp.new(switchboard_and_desk_entity_code_pattern) then ['switchboard_and_desk', code[1]]
        when Regexp.new(miscellaneous_switching_termination_entity_code_pattern) then ['miscellaneous_switching_termination', code[1]]
        when Regexp.new(nonswitching_entity_code_pattern) then ['nonswitching_types', code[0]]
        end
      end
    end
  end
end

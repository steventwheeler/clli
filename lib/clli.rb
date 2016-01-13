require 'countries'
require 'clli/version'
require 'clli/pattern'
require 'clli/iso3166'
require 'clli/yaml_data'
require 'clli/entity_type'
require 'clli/location_type'
require 'clli/validations'
require 'clli/cities'

##
# This is the base Common Language Location Identification (CLLI) class. The
# parser is based on the Bell System Practices document Section 795-100-100.
#
# = Example
#
# clli = CLLI.new('MPLSMNMSDS1')
# clli.place        # 'MPLS'
# clli.region       # 'MN'
# clli.network_site # 'MS'
# clli.entity_code  # 'DS1'
# clli.entity_type  # 'End Office Complete Switching System: Electonic-Digital'
# clli.city_name    # 'Minneapolis'
# clli.state_code   # 'MN'
# clli.state_name   # 'Minnesota'
# clli.country_code # 'US'
# clli.country_name # 'United States'
class CLLI
  include Pattern
  include EntityType
  include LocationType
  include Validations
  include ISO3166
  include Cities

  attr_reader :attributes

  ##
  # Create a new +CLLI+ by parsing +str+.
  #
  # A RuntimeError is raised if the string does not represent a valid +CLLI+.
  #
  # Params:
  # +str+::     the CLLI string to parse.
  # +options+:: options which change the behavior of the parser. See
  #             +CLLI::Pattern.pattern+ for more information.
  def initialize(str, **options)
    @attributes = parse(str, options)
  end

  ##
  # Get the ISO 3166 two character state code this +CLLI+ is located in.
  def state_code
    self.class.iso_state(region)
  end

  ##
  # Get the name of the state this +CLLI+ is located in.
  def state_name
    self.class.state_name(region)
  end

  ##
  # Get the ISO 3166 two character country code this +CLLI+ is located in.
  def country_code
    self.class.iso_country(region)
  end

  ##
  # Get the name of the country this +CLLI+ is located in.
  def country_name
    self.class.country_name(region)
  end

  ##
  # Get the name of the city this +CLLI+ is located in if known.
  def city_name
    self.class.city_name(place, region)
  end

  ##
  # Get a string describing the location code for this +CLLI+. Note, if this is
  # an entity +CLLI+ then the return value will be +nil+.
  def location_type
    return self.class.location_type(location_code) if respond_to?(:location_code)
    return self.class.location_type(customer_code) if respond_to?(:customer_code)
  end

  ##
  # Get a string describing the entity code for this +CLLI+. Note, if this is
  # not an entity +CLLI+ then the return value will be +nil+.
  def entity_type
    return self.class.entity_type(entity_code) if respond_to?(:entity_code)
  end

  ##
  # Allows the user to access attribute values as methods.
  def method_missing(method, *args)
    return @attributes[method] if @attributes.key?(method)
    super
  end

  ##
  # Allows the user to check whether or not attributes exist.
  def respond_to?(method)
    return true if @attributes.key?(method)
    super
  end

  private

  ##
  # Parse the +str+ into a +Hash+ containing the +CLLI+ attributes.
  #
  # Params:
  # +str+::     the CLLI string to parse.
  # +options+:: options which change the behavior of the parser. See
  #             +CLLI::Pattern.pattern+ for more information.
  def parse(str, **options)
    # Parse the string using the CLLI pattern.
    match_data = self.class.regexp(options).match(str)

    # Raise an error if the string did not match the pattern.
    fail "#{str.inspect} is not a valid CLLI." if match_data.nil?

    # Import the data from the pattern's named groups.
    attributes = convert_match_data(match_data)

    # Verify the attribute values.
    self.class.validate(str, attributes, options)

    # Places can be less than four characters. In which case they are left
    # justified and padded to four characters using spaces.
    attributes[:place] = attributes[:place].strip

    attributes.freeze
  end

  ##
  # Convert the +MatchData+ object into a +hash+.
  #
  # Params:
  # +match_data+::  a +MatchData+ object.
  def convert_match_data(match_data)
    match_data.names.map(&:to_sym).each_with_object({}) do |attribute, hash|
      value = match_data[attribute]
      next if value.nil?
      hash[attribute] = value
    end
  end
end

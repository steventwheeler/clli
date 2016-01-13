require 'test_helper'
require 'csv'

class CLLITest < Minitest::Test
  test 'must report the current version number' do
    refute_nil ::CLLI::VERSION
  end

  test 'must be able to parse valid CLLI strings' do
    tests = load_data(%w(data clli_test.yml))
    tests.each do |clli, result|
      clli = clli.to_s
      c = CLLI.new(clli)
      result.keys.each do |attribute|
        actual = c.respond_to?(attribute) ? c.send(attribute) : nil
        assert_equal result[attribute], actual, "#{clli.inspect} has an invalid attribute #{attribute.inspect} in #{c.attributes.inspect}"
      end
    end
  end

  test 'must not parse invalid CLLI strings' do
    tests = [nil, '', 'MP SMNMA01T']
    tests.each do |clli|
      assert_raises(RuntimeError, "#{clli.inspect} should not be parseable") do
        CLLI.new(clli)
      end
    end
  end

  test 'must be able to parse telcodata.us NANPA thousands file' do
    file = ENV['NANPA_THOUSANDS_FILE']
    skip('Specify NANPA_THOUSANDS_FILE environment variable to run this test.') if file.nil? || !File.exist?(file)

    CSV.foreach(file) do |row|
      original_clli = clli = row[7].strip
      next if clli.size != 8 && clli.size != 11

      # Normalize the CLLI.
      (0..5).each do |i|
        clli[i] = 'I' if clli[i] == '1'
        clli[i] = 'O' if clli[i] == '0'
      end
      next if original_clli != clli

      refute_nil CLLI.new(clli, strict: false), "failed to parse #{clli.inspect}"
    end
  end
end

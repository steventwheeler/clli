require 'test_helper'

class ISO3166Test < Minitest::Test

  test 'convert region code to country code' do
    tests = {
      'MN' => 'US',
      'PQ' => 'CA',
      'HS' => 'XZ',
      'EO' => 'XS'
    }
    tests.each do |region_code, country|
      assert_equal country, CLLI.iso_country(region_code), "Region code #{region_code.inspect} should be converted to country #{country}"
    end
  end

  test 'convert region code to country name' do
    tests = {
      'MN' => 'United States',
      'PQ' => 'Canada',
      'HS' => nil,
      'EO' => nil
    }
    tests.each do |region_code, country|
      assert_equal country, CLLI.country_name(region_code), "Region code #{region_code.inspect} should be converted to country #{country}"
    end
  end

  test 'convert region code to state code' do
    tests = {
      'MN' => 'MN',
      'PQ' => 'QC',
      'HS' => nil,
      'EO' => nil
    }
    tests.each do |region_code, state|
      assert_equal state, CLLI.iso_state(region_code), "Region code #{region_code.inspect} should be converted to state #{state}"
    end
  end

  test 'convert region code to country name' do
    tests = {
      'MN' => 'Minnesota',
      'PQ' => 'Quebec',
      'HS' => nil,
      'EO' => nil
    }
    tests.each do |region_code, state|
      assert_equal state, CLLI.state_name(region_code), "Region code #{region_code.inspect} should be converted to state #{state}"
    end
  end
end

require 'test_helper'
require 'csv'

class PatternTest < Minitest::Test
  test 'must match the character classes' do
    tests = {
      CLLI.a =>  { valid: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', invalid: '0123456789 -' },
      CLLI.a1 => { valid: 'ACEFGHJKLMNPQRSVXZ', invalid: 'BDIOTUWY0123456789 -' },
      CLLI.a2 => { valid: 'ABCDEFHIJKLMNOPQRSTUVWXYZ', invalid: 'G0123456789 -' },
      CLLI.x =>  { valid: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', invalid: ' -' },
      CLLI.x1 => { valid: 'ACEFGHJKLMNPQRSVXZ0123456789', invalid: 'BDIOTUWY -' },
      CLLI.x2 => { valid: 'ABCDEFHIJKLMNOPQRSTUVWXYZ0123456789', invalid: 'G -' },
    }
    tests.each do |pattern, cases|
      regex = Regexp.new("\\A[#{pattern}]\\z")
      cases[:valid].chars.each do |c|
        assert_match regex, c, "#{c.inspect} should match the character class #{pattern}"
      end
      cases[:invalid].chars.each do |c|
        refute_match regex, c, "#{c.inspect} should match the character class #{pattern}"
      end
    end
  end

  test 'must be able to parse valid entity codes' do
    regex = Regexp.new(CLLI.entity_code_pattern)
    valid_codes = %w(MG1 MGN SG1 2CB 2DB 3DB 2IB 2NB 4QB 2WB 2MB 2VB 2RB 5OB 3LB 26B 3PB 3EB 2UB 2TB 2ZB 3AD 3XD 2CD 5TD 2WD 4DD 2ED 3ID 2ND 2PD 2QD 2UD 7MD F23 AA3 E3A K32 MA2 P34 Q23 SP2 TTR WVL)
    valid_codes.each do |code|
      assert_match regex, code, "#{code.inspect} shoud be a valid entity code"
    end
  end

  test 'must not be able to parse invalid entity codes' do
    regex = Regexp.new(CLLI.entity_code_pattern)
    invalid_codes = %w(ACB F0Y FG0 Q0A)
    invalid_codes.each do |code|
      refute_match regex, code, "#{code.inspect} should not be a valid entity code"
    end
  end

  test 'must be able to parse non-building location codes' do
    regex = Regexp.new(CLLI.nonbuilding_location_pattern)
    valid_codes = %w(B1234 E2345 J4523 M9876 P8834 Q5634 R3459 S3344 U8877 X1234)
    valid_codes.each do |code|
      assert_match regex, code, "#{code.inspect} shoud be a valid non=building location code"
    end
  end

  test 'must be able to parse customer location codes' do
    regex = Regexp.new(CLLI.customer_location_pattern)
    valid_codes = %w(1A234)
    valid_codes.each do |code|
      assert_match regex, code, "#{code.inspect} shoud be a valid customer location code"
    end
  end
end

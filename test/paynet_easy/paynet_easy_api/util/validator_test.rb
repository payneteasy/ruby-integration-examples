require 'test/unit'
require 'paynet_easy_api'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Util
  class ValidatorTest < Test::Unit::TestCase

    def test_validate_by_rule
      [
        ['test@mail.com',          Validator::EMAIL,       true],
        ['test[a]mail.com',        Validator::EMAIL,       false],
        ['127.0.0.1',              Validator::IP,          true],
        ['260.0.0.1',              Validator::IP,          false],
        ['http://site.com',        Validator::URL,         true],
        ['site.com',               Validator::URL,         false],
        ['site-com',               Validator::URL,         false],
        ['1',                      Validator::MONTH,       true],
        ['12',                     Validator::MONTH,       true],
        ['13',                     Validator::MONTH,       false],
        ['0',                      Validator::MONTH,       false],
        ['str',                    Validator::MONTH,       false],
        ['str',                    Validator::MONTH,       false],
        ['US',                     Validator::COUNTRY,     true],
        ['USA',                    Validator::COUNTRY,     false],
        ['(086)543 543 54',        Validator::PHONE,       true],
        ['(086)s543b543',          Validator::PHONE,       false],
        ['0.98',                   Validator::AMOUNT,      true],
        ['98 000',                 Validator::AMOUNT,      false],
        ['USD',                    Validator::CURRENCY,    true],
        ['$',                      Validator::CURRENCY,    false],
        ['23e2d3rf3f4',            Validator::ID,          true]
      ]
      .each do |value, rule, expected_result|
        actual_result = Validator.validate_by_rule value, rule, false
        assert_equal expected_result, actual_result, "On rule '#{rule}' and value '#{value}'"
      end
    end
  end
end
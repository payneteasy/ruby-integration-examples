require 'contracts'
require 'uri'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Util
  module Validator
    include Contracts
    include PaynetEasy::PaynetEasyApi::Error

    URL = 'url'

    # Validates value by given rule.
    # Rule can be one of Validator constants or regExp.
    #
    # @param    value           [Object]                  Value for validation
    # @param    rule            [String]                  Rule for validation
    # @param    fail_on_error   [TrueClass|FalseClass]    Throw exception on invalid value or not
    #
    # @return                   [TrueClass|FalseClass]    Validation result
    def self.validate_by_rule(value, rule, fail_on_error)
      valid = case rule
      when URL then value =~ URI::ABS_URI
      end

      if valid
        true
      elsif fail_on_error
        raise ValidationError, "Value '#{value}' does not match rule '#{rule}'"
      else
        false
      end
    end
  end
end
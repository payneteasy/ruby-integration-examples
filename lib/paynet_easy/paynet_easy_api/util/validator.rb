require 'uri'
require 'ipaddr'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Util
  module Validator
    include PaynetEasy::PaynetEasyApi::Error

    # Validate value as email
    EMAIL = 'email'

    # Validate value as IP address
    IP    = 'ip'

    # Validate value as URL
    URL   = 'url'

    # Validate value as month
    MONTH = 'month'

    # Validate value as year
    YEAR  = 'year'

    # Validate value as phone number
    PHONE = 'phone'

    # Validate value as payment amount
    AMOUNT = 'amount'

    # Validate value as currency
    CURRENCY  = 'currency'

    # Validate value as card verification value
    CVV2      = 'cvv2'

    # Validate value as zip code
    ZIP_CODE  = 'zip_code'

    # Validate value as two-letter country or state code
    COUNTRY   = 'country'

    # Validate value as date in format MMDDYY
    DATE      = 'date'

    # Validate value as  last four digits of social security number
    SSN       = 'ssn'

    # Validate value as credit card number
    CREDIT_CARD_NUMBER = 'credit_card_number'

    # Validate value as different IDs (client, paynet, card-ref)
    ID        = 'id'

    # Validate value as medium string
    MEDIUM_STRING = 'medium_string'

    # Validate value as long string
    LONG_STRING   = 'long_string'

    # Regular expressions for some validation rules
    @@rule_regexps =
    {
        EMAIL                 => /@+/,
        PHONE                 => /^[0-9\-\+\(\)\s]{6,15}$/i,
        AMOUNT                => /^[0-9\.]{1,11}$/i,
        CURRENCY              => /^[A-Z]{1,3}$/i,
        CVV2                  => /^[\S\s]{3,4}$/i,
        ZIP_CODE              => /^[\S\s]{1,10}$/i,
        COUNTRY               => /^[A-Z]{1,2}$/i,
        YEAR                  => /^[0-9]{1,2}$/i,
        DATE                  => /^[0-9]{6}$/i,
        SSN                   => /^[0-9]{1,4}$/i,
        CREDIT_CARD_NUMBER    => /^[0-9]{1,20}$/i,
        ID                    => /^[\S\s]{1,20}$/i,
        MEDIUM_STRING         => /^[\S\s]{1,50}$/i,
        LONG_STRING           => /^[\S\s]{1,128}$/i
    }

    # Validates value by given rule.
    # Rule can be one of Validator constants or regExp.
    #
    # @param    value           [Object]                  Value for validation
    # @param    rule            [String|Regexp]           Rule for validation
    # @param    fail_on_error   [TrueClass|FalseClass]    Throw exception on invalid value or not
    #
    # @return                   [TrueClass|FalseClass]    Validation result
    def self.validate_by_rule(value, rule, fail_on_error = true)
      begin
        valid = case rule
        when URL    then URI::ABS_URI === value
        when IP     then IPAddr.new value
        when MONTH  then (1..12).include? value.to_i
        else
          regexp = @@rule_regexps.key?(rule) ? @@rule_regexps[rule] : rule
          regexp === value.to_s
        end
      rescue Exception
        valid = false
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
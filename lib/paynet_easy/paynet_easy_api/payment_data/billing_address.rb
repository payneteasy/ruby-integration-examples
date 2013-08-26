require 'payment_data/data'

module PaynetEasy::PaynetEasyApi::PaymentData
  class BillingAddress < Data
    # Customer’s address line 1
    #
    # @var [String]
    attr_accessor :first_line

    # Customer’s city
    #
    # @var [String]
    attr_accessor :city

    # Customer’s state (two-letter US state code).
    # Not applicable outside the US.
    #
    # @var [String]
    attr_accessor :state

    # Customer’s ZIP code
    #
    # @var [String]
    attr_accessor :zip_code

    # Customer’s country (two-letter country code)
    #
    # @var [String]
    attr_accessor :country

    # Customer’s full international phone number, including country code.
    #
    # @var [String]
    attr_accessor :phone

    # Customer’s full international cell phone number, including country code.
    #
    # @var [String]
    attr_accessor :cell_phone
  end
end
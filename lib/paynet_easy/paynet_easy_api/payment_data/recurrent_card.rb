require 'payment_data/data'

module PaynetEasy::PaynetEasyApi::PaymentData
  class RecurrentCard < Data
    # RecurrentCard reference ID
    #
    # @var [String]
    attr_accessor :paynet_id

    # RecurrentCard CVV2
    #
    # @var [String]
    attr_accessor :cvv2

    # Card holder name
    #
    # @var [String]
    attr_accessor :card_printed_name

    # Card expiration year
    #
    # @var [String]
    attr_accessor :expire_year

    # Card expiration month
    #
    # @var [String]
    attr_accessor :expire_month

    # Bank Identification Number
    #
    # @var [String]
    attr_accessor :bin

    # The last four digits of PAN (card number)
    #
    # @var [String]
    attr_accessor :last_four_digits
  end
end
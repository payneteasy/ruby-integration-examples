module PaynetEasy::PaynetEasyApi::PaymentData
  class CreditCard < Data
    # CreditCard CVV2
    #
    # @var [String]
    attr_accessor :cvv2

    # Card holder name
    #
    # @var [String]
    attr_accessor :card_printed_name

    # Credit card number
    #
    # @var [String]
    attr_accessor :credit_card_number

    # Card expiration year
    #
    # @var [String]
    attr_accessor :expire_year

    # Card expiration month
    #
    # @var [String]
    attr_accessor :expire_month

    def credit_card_number=(credit_card_number)
      @credit_card_number = credit_card_number.gsub(/\s|-|_|\.|,/, '')
    end
  end
end
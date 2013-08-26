require 'payment_data/data'

module PaynetEasy::PaynetEasyApi::PaymentData
  class Customer < Data
    # Customer’s first name
    #
    # @var [String]
    attr_accessor :first_name

    # Customer’s last name
    #
    # @var [String]
    attr_accessor :last_name

    # Customer’s email address
    #
    # @var [String]
    attr_accessor :email

    # Customer’s IP address
    #
    # @var [String]
    attr_accessor :ip_address

    # Customer’s date of birth, in the format MMDDYY
    #
    # @var [String]
    attr_accessor :birthday

    # Last four digits of the customer’s social security number
    #
    # @var [String]
    attr_accessor :ssn
  end
end
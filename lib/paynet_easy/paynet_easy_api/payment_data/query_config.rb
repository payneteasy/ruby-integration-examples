require 'contracts'
require 'payment_data/data'

module PaynetEasy::PaynetEasyApi::PaymentData
  class QueryConfig < Data
    include Contracts

    # Execute query to PaynetEasy sandbox gateway
    GATEWAY_MODE_SANDBOX      = 'sandbox'

    # Execute query to PaynetEasy production gateway
    GATEWAY_MODE_PRODUCTION   = 'production'

    # Allowed gateway modes
    @@allowed_gateway_modes =
    [
      GATEWAY_MODE_SANDBOX,
      GATEWAY_MODE_PRODUCTION
    ]

    # Merchant end point
    #
    # @var [String]
    attr_accessor :end_point

    # Merchant login
    #
    # @var [String]
    attr_accessor :login

    # Merchant key for payment signing
    #
    # @var [String]
    attr_accessor :signing_key

    # URL the original payment is made from
    #
    # @var [String]
    attr_accessor :site_url

    # URL the customer will be redirected to upon completion of the transaction
    #
    # @var [String]
    attr_accessor :redirect_url

    # URL the transaction result will be sent to
    #
    # @var [String]
    attr_accessor :callback_url

    # PaynetEasy gateway mode: sandbox or production
    #
    # @var [String]
    attr_accessor :gateway_mode

    # PaynetEasy sandbox gateway URL
    #
    # @var [String]
    attr_accessor :gateway_url_sandbox

    # PaynetEasy production gateway URL
    #
    # @var [String]
    attr_accessor :gateway_url_production

    Contract String => Any
    def gateway_mode=(gateway_mode)
      check_gateway_mode gateway_mode
      @gateway_mode = gateway_mode
    end

    Contract None => String
    # Get gateway url for current gateway mode
    #
    # @return   [String]    Sandbox gateway url if gateway mode is sandbox,
    #                       production gateway url if gateway mode is production
    def gateway_url
      case gateway_mode
      when GATEWAY_MODE_SANDBOX     then gateway_url_sandbox
      when GATEWAY_MODE_PRODUCTION  then gateway_url_production
      else raise RuntimeError, 'You must set gateway_mode property first'
      end
    end

    protected

    Contract String => Any
    # Checks, is gateway mode allowed or not
    #
    # @param    gateway_mode    [String]    Gateway mode to check
    def check_gateway_mode(gateway_mode)
      unless @@allowed_gateway_modes.include? gateway_mode
        raise ArgumentError, "Unknown gateway mode given: '#{gateway_mode}'"
      end
    end
  end
end
require 'contracts'
require 'data'

module PaynetEasy::PaynetEasyApi::PaymentData
  class Payment < Data
    include Contracts

    # Payment is new, and not processing
    STATUS_NEW        = 'new'

    # Payment is under preauth, or preauth is finished
    STATUS_PREAUTH    = 'preauth'

    # Payment is under capture, or capture is finished
    STATUS_CAPTURE    = 'capture'

    # Payment is under return, or return is finished
    STATUS_RETURN     = 'return'

    # All allowed payment statuses
    @@allowed_statuses =
    [
      STATUS_PREAUTH,
      STATUS_CAPTURE,
      STATUS_RETURN
    ]

    # Unique identifier of payment assigned by merchant
    #
    # @var [String]
    attr_accessor :client_id

    # Unique identifier of payment assigned by PaynetEasy
    #
    # @var [String]
    attr_accessor :paynet_id

    # Brief payment description
    #
    # @var [String]
    attr_accessor :description

    # Destination to where the payment goes
    #
    # @var [String]
    attr_accessor :destination

    # Amount to be charged
    #
    # @var [Float]
    attr_accessor :amount

    # Currency the transaction is charged in (three-letter currency code)
    #
    # @var [String]
    attr_accessor :currency

    # A short comment for payment
    #
    # @var [String]
    attr_accessor :comment

    # Payment status
    #
    # @var [String]
    attr_accessor :status

    # Payment customer
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::Customer]
    attr_accessor :customer

    # Payment billing address
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::BillingAddress]
    attr_accessor :billing_address

    # Payment credit card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::CreditCard]
    attr_accessor :credit_card

    # Payment source recurrent card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard]
    attr_accessor :recurrent_card_from

    # Payment destination recurrent card
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::RecurrentCard]
    attr_accessor :recurrent_card_to

    # Payment transactions for payment
    #
    # @var  [Array]
    attr_accessor :payment_transactions

    Contract None => Integer
    def amount_in_cents
      (amount * 100).to_i
    end

    Contract Customer => None
    def customer=(customer)
      @customer = customer
    end

    Contract None => Customer
    def customer
      @customer ||= Customer.new
    end

    Contract BillingAddress => None
    def billing_address=(billing_address)
      @billing_address = billing_address
    end

    Contract None => BillingAddress
    def billing_address
      @billing_address ||= BillingAddress.new
    end

    Contract CreditCard => None
    def credit_card=(credit_card)
      @credit_card = credit_card
    end

    Contract None => CreditCard
    def credit_card
      @credit_card ||= CreditCard.new
    end

    Contract RecurrentCard => None
    def recurrent_card_from=(recurrent_card)
      @recurrent_card_from = recurrent_card
    end

    Contract None => RecurrentCard
    def recurrent_card_from
      @recurrent_card_from ||= RecurrentCard.new
    end

    Contract RecurrentCard => None
    def recurrent_card_to=(recurrent_card)
      @recurrent_card_to = recurrent_card
    end

    Contract None => RecurrentCard
    def recurrent_card_to
      @recurrent_card_to ||= RecurrentCard.new
    end

    Contract None => ArrayOf[PaymentTransaction]
    def payment_transactions
      @payment_transactions ||= []
    end

    Contract PaymentTransaction => None
    def add_payment_transaction(payment_transaction)
      unless has_payment_transaction? payment_transaction
        @payment_transactions << payment_transaction
      end

      unless payment_transaction.payment === self
        payment_transaction.payment = self
      end
    end

    Contract PaymentTransaction => Bool
    def has_payment_transaction?(payment_transaction)
      payment_transactions.include? payment_transaction
    end

    Contract None => Bool
    # True, if the payment has a transaction that is currently being processed
    def has_processing_transaction?
      payment_transactions.detect &:processing?
    end

    Contract String => None
    def status=(status)
      unless @@allowed_statuses.include? status
        raise ArgumentError, "Unknown payment status given: '#{status}'"
      end

      @status = status
    end

    Contract None => Bool
    # True, if payment is new
    def new?
      status == STATUS_NEW
    end

    Contract None => Bool
    # True, is payment is paid up
    def paid?
      [STATUS_PREAUTH, STATUS_CAPTURE].include? status
    end

    Contract None => Bool
    # True, if funds returned to customer
    def returned?
      status == STATUS_RETURN
    end
  end
end
require 'contracts'
require 'query/prototype/query'
require 'util/validator'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Query
  class CreateCardRefQuery < Prototype::Query
    include Contracts
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Error

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',     'payment.client_id',             true,   Validator::ID],
      ['orderid',            'payment.paynet_id',             true,   Validator::ID],
      ['login',              'query_config.login',            true,   Validator::MEDIUM_STRING]
    ]

    @@signature_definition =
    [
      'query_config.login',
      'payment.client_id',
      'payment.paynet_id',
      'query_config.signing_key'
    ]

    @@response_fields_definition =
    [
      'type',
      'status',
      'card-ref-id',
      'serial-number'
    ]

    @@success_response_type = 'create-card-ref-response'

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for validation
    def validate_payment_transaction(payment_transaction)
      check_payment_transaction_status payment_transaction
      super payment_transaction
    end

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for validating
    def validate_response_on_success(payment_transaction, response)
      check_payment_transaction_status payment_transaction
      super payment_transaction, response
    end

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for validating
    def validate_response_on_error(payment_transaction, response)
      check_payment_transaction_status payment_transaction
      super payment_transaction, response
    end

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction
    # @param    response              [Response]              Response for payment transaction updating
    def update_payment_transaction_on_success(payment_transaction, response)
      payment_transaction.payment.recurrent_card_from.paynet_id = response.card_paynet_id
    end

    Contract PaymentTransaction => Any
    # Check, if payment transaction is finished and payment is not new.
    #
    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for validation
    def check_payment_transaction_status(payment_transaction)
      unless payment_transaction.finished?
        raise ValidationError, 'Only finished payment transaction can be used for create-card-ref-id'
      end

      unless payment_transaction.payment.paid?
        raise ValidationError, "Can not use new payment for create-card-ref-id. Execute 'sale' or 'preauth' query first"
      end
    end
  end
end
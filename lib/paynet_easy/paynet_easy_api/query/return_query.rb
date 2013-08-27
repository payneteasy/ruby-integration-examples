require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'
require 'error/validation_error'

module PaynetEasy::PaynetEasyApi::Query
  class ReturnQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util
    include PaynetEasy::PaynetEasyApi::Error

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',     'payment.client_id',                true,   Validator::ID],
      ['orderid',            'payment.paynet_id',                true,   Validator::ID],
      ['amount',             'payment.amount',                   true,   Validator::AMOUNT],
      ['currency',           'payment.currency',                 true,   Validator::CURRENCY],
      ['comment',            'payment.comment',                  true,   Validator::MEDIUM_STRING],
      ['login',              'query_config.login',               true,   Validator::MEDIUM_STRING]
    ]

    @@signature_definition =
    [
      'query_config.login',
      'payment.client_id',
      'payment.paynet_id',
      'payment.amount_in_cents',
      'payment.currency',
      'query_config.signing_key'
    ]

    @@payment_status = Payment::STATUS_RETURN

    protected

    # @param    payment_transaction   [PaymentTransaction]    Payment transaction for validation
    def validate_payment_transaction(payment_transaction)
      unless payment_transaction.payment.paid?
        raise ValidationError, 'Payment must be paid up to return funds'
      end

      super payment_transaction
    end
  end
end
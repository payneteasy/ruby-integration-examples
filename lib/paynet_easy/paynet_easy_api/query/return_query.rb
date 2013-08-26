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
      ['client_orderid',     'payment.clientId',                 true,   Validator::ID],
      ['orderid',            'payment.paynetId',                 true,   Validator::ID],
      ['amount',             'payment.amount',                   true,   Validator::AMOUNT],
      ['currency',           'payment.currency',                 true,   Validator::CURRENCY],
      ['comment',            'payment.comment',                  true,   Validator::MEDIUM_STRING],
      ['login',              'queryConfig.login',                true,   Validator::MEDIUM_STRING]
    ]

    @@signature_definition =
    [
      'queryConfig.login',
      'payment.clientId',
      'payment.paynetId',
      'payment.amountInCents',
      'payment.currency',
      'queryConfig.signingKey'
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
require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class CaptureQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',     'payment.clientId',             true,   Validator::ID],
      ['orderid',            'payment.paynetId',             true,   Validator::ID],
      ['login',              'queryConfig.login',            true,   Validator::MEDIUM_STRING]
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

    @@payment_status = Payment::STATUS_CAPTURE
  end
end
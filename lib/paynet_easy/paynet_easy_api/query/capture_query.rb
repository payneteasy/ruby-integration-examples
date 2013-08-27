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
      ['client_orderid',     'payment.client_id',             true,   Validator::ID],
      ['orderid',            'payment.paynet_id',             true,   Validator::ID],
      ['login',              'query_config.login',            true,   Validator::MEDIUM_STRING]
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

    @@payment_status = Payment::STATUS_CAPTURE
  end
end
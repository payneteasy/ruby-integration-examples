require 'query/prototype/payment_query'
require 'payment_data/payment'
require 'util/validator'

module PaynetEasy::PaynetEasyApi::Query
  class MakeRebillQuery < Prototype::PaymentQuery
    include PaynetEasy::PaynetEasyApi::PaymentData
    include PaynetEasy::PaynetEasyApi::Util

    @@request_fields_definition =
    [
      # mandatory
      ['client_orderid',         'payment.client_id',                            true,    Validator::ID],
      ['order_desc',             'payment.description',                          true,    Validator::LONG_STRING],
      ['amount',                 'payment.amount',                               true,    Validator::AMOUNT],
      ['currency',               'payment.currency',                             true,    Validator::CURRENCY],
      ['ipaddress',              'payment.customer.ip_address',                  true,    Validator::IP],
      ['cardrefid',              'payment.recurrent_card_from.paynet_id',        true,    Validator::ID],
      ['login',                  'query_config.login',                           true,    Validator::MEDIUM_STRING],
      # optional
      ['comment',                'payment.comment',                              false,   Validator::MEDIUM_STRING],
      ['cvv2',                   'payment.recurrent_card_from.cvv2',             false,   Validator::CVV2],
      ['server_callback_url',    'query_config.callback_url',                    false,   Validator::URL]
    ]

    @@signature_definition =
    [
      'query_config.end_point',
      'payment.client_id',
      'payment.amount_in_cents',
      'payment.recurrent_card_from.paynet_id',
      'query_config.signing_key'
    ]

    @@payment_status = Payment::STATUS_CAPTURE
  end
end